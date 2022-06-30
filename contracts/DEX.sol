//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** @title EVM wallet generator
 *  @author David Camps Novi
 *  @dev This contract is a simple DEX that allows any user to perform 3 types of operations:
 *      - Swap coins --> introduce amount of a token A to receive its equivalent in token B
 *      - Stake coins --> introduce amount of token A to be locked into this contract to produce yield
 *      - Blind DCA --> approve how much USD you allow the DEX to spend periodically on a randomly selected coin
 */
contract DEX is VRFConsumerBaseV2, KeeperCompatibleInterface, Ownable {
    /* VRF */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 public constant INTERVAL = 1; //to be defined!!
    uint256 public lastTimeStamp;

    /* Data Feeds */
    address[] private s_tokenList;
    mapping(address => AggregatorV3Interface) private s_priceFeeds;
    mapping(address => uint256) private s_tokenToUsd;

    /* Staking */
    mapping(address => mapping(address => uint256)) private s_staked;

    /* DCA */
    address private s_dailyToken;
    address[] private s_dcaUsers;
    mapping(address => uint256) private s_dcaAmount;
    mapping(address => mapping(address => uint256)) private s_balances;

    /* DEX treasury */
    mapping(address => uint256) private s_treasury;

    event Swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
    event DcaSet(uint256 allowance, uint256 dcaAmount);
    event DcaBuy(
        address buyer,
        uint256 amountInUsd,
        address tokenOut,
        uint256 amountTokenOut
    );
    event Stake(address owner, address token, uint256 amount);

    constructor(
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        address _ethUsdPriceFeed,
        address _btcUsdtPriceFeed,
        address[] memory _tokens
    ) VRFConsumerBaseV2(_vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        s_priceFeeds[_ethUsdPriceFeed] = AggregatorV3Interface(
            _ethUsdPriceFeed
        );
        s_priceFeeds[_btcUsdtPriceFeed] = AggregatorV3Interface(
            _btcUsdtPriceFeed
        );
        for (uint256 i; i < _tokens.length; i++) {
            s_tokenList[i] = _tokens[i];
        }
    }

    /**
     *  @notice This function allows to swap any pair of tokens
     *  @dev
     */
    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) public {
        uint256 amountOut;

        if (_tokenIn == s_tokenList[0]) {
            amountOut = _amountIn / s_tokenToUsd[_tokenOut];
        } else {
            amountOut =
                (_amountIn * s_tokenToUsd[_tokenIn]) /
                s_tokenToUsd[_tokenOut];
        }

        s_treasury[_tokenOut] -= amountOut; //POTENTIAL ERROR (NOT ENOUGH BALANCE)
        s_treasury[_tokenIn] += _amountIn;

        IERC20(_tokenIn).approve(address(this), _amountIn);
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn); //POTENTIAL ERROR (NOT ENOUGH BALANCE)
        IERC20(_tokenOut).transferFrom(address(this), msg.sender, amountOut); //POTENTIAL ERROR (NOT ENOUGH BALANCE)

        emit Swap(_tokenIn, _tokenOut, _amountIn, amountOut);
    }

    /**
     *  @notice
     *  @dev
     */
    function stake(address _token, uint256 _amount) external payable {
        s_staked[msg.sender][_token] += _amount;
        //uint256 stakeTime = block.timestamp;
        //uint256 farmed = (block.timestamp - stakeTime) * yield;
        IERC20(_token).transferFrom(msg.sender, address(this), _amount); //POTENTIAL ERROR NOT ENOUGH BALANCE

        emit Stake(msg.sender, _token, _amount);
    }

    /**
     *  @notice
     *  @dev
     *  @param _deposit is to the total amount of USD we allow the DEX to spend (aka allowance)
     *  @param _amount is the amount of USD we want to spend in each DCA buy
     */
    function setDca(uint256 _deposit, uint256 _amount) external {
        IERC20(s_tokenList[0]).approve(address(this), _deposit); //POTENTIAL ERROR (NOT ENOUGH BALANCE)
        s_dcaUsers.push(msg.sender);
        s_dcaAmount[msg.sender] = _amount;

        emit DcaSet(_deposit, _amount);
    }

    function _buyDca(
        address _recipient,
        uint256 _amount,
        address _tokenOut
    ) private {
        uint256 amountOut = _amount / s_tokenToUsd[_tokenOut];

        s_balances[_recipient][s_tokenList[0]] -= _amount; //POTENTIAL ERROR (NOT ENOUGH BALANCE)
        s_balances[_recipient][_tokenOut] += _amount;
        s_treasury[_tokenOut] -= _amount; //POTENTIAL ERROR (NOT ENOUGH BALANCE)
        s_treasury[s_tokenList[0]] += _amount;

        IERC20(s_tokenList[0]).transferFrom(_recipient, address(this), _amount); //POTENTIAL ERROR (NOT ENOUGH BALANCE)
        IERC20(_tokenOut).transferFrom(address(this), _recipient, _amount); //POTENTIAL ERROR (NOT ENOUGH BALANCE)

        emit DcaBuy(_recipient, _amount, _tokenOut, amountOut);
    }

    /**
     *  @notice This function updates the prices of all tokens
     */
    function _updateTokenPrices() private {
        for (uint256 i; i < s_tokenList.length; i++) {
            address token = s_tokenList[i];
            (, int256 tokenPrice, , , ) = (s_priceFeeds[token])
                .latestRoundData();
            s_tokenToUsd[token] = uint256(tokenPrice);
        }
    }

    /**
     *  @dev This function requests a random value to the Chainlink VRF nodes and returns
     *  an ID for that request. To get the random value, a second call to the oracle is
     *  necessary, done through the function fulfillRandomWords()
     */
    function _requestId() private returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        return requestId;
    }

    /**
     *  @notice This function returns a random value from 0 to 2
     *  @dev This function returns a modded randomWords from the Chainlink VRF
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 tokenId = (randomWords[0] % 1) + 1;
        s_dailyToken = s_tokenList[tokenId];
    }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > INTERVAL;
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
        lastTimeStamp = block.timestamp;

        for (uint256 i; i < s_dcaUsers.length; i++) {
            _buyDca(s_dcaUsers[i], s_dcaAmount[msg.sender], s_dailyToken); // POTENTIAL ERROR (NOT ENOUGH BALANCE)
        }
        _updateTokenPrices();
        _requestId();
        performData;
    }

    function getTokenPrice(address _token) external view returns (uint256) {
        return s_tokenToUsd[_token];
    }

    function getDailyToken() external view returns (address) {
        return s_dailyToken;
    }
}
