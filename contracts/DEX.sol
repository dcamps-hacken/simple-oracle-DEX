//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** @title EVM wallet generator
 *  @author David Camps Novi
 *  @dev This contract is a simple DEX that allows any user to perform 3 types of operations:
 *      - Swap coins --> introduce amount of a token A to receive its equivalent in token B
 *      - Stake coins --> introduce amount of token A to be locked into this contract to produce yield
 *      - Blind DCA --> approve how much USD you allow the DEX to spend periodically on a randomly selected coin
 */
contract DEX is VRFConsumerBaseV2, Ownable {

    /* VRF */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 public constant INTERVAL;
    uint256 public lastTimeStamp;

    /* Data Feeds */
    address[] private immutable i_tokenList;
    mapping(address => uint256) private s_tokenToUsd;
    mapping(address => AggregatorV3Interface) s_priceFeeds;

    /* Staking */
    mapping (address => mapping (address => uint256)) s_staked;

    /* DCA */
    address private s_dailyToken;
    address[] private s_dca;
    mapping (address => mapping (address => uint256)) s_balances;

    /* DEX treasury */
    mapping (address => uint256) s_treasury;

    Event Swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    Event PriceUpdate(address token, uint256 newPrice);


    constructor(
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        address _ethUsdPriceFeed,
        address _btcUsdtPriceFeed,
        address[] _tokens
    )
        VRFConsumerBaseV2(_vrfCoordinatorV2)
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        s_priceFeeds[_ethUsdPriceFeed] = AggregatorV3Interface(_ethUsdPriceFeed);
        s_priceFeeds[_btcUsdtPriceFeed] = AggregatorV3Interface(_btcUsdtPriceFeed);
        for (uint256 i; i < _tokens.length; i++){
            i_tokenList.push(_tokens[i]);
        }
    }

    /**
     *  @notice This function allows to swap any pair of tokens
     *  @dev 
     */
    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn) public {
        uint256 amountOut;
        if (_tokenIn == USD) {
            amountOut = _amountIn / s_tokenToUsd[_tokenOut]
        } else {
            amountOut = _amountIn*s_tokenToUsd[_tokenIn]/s_tokenToUsd[_tokenOut];
        }
        s_treasury[_tokenOut] -= amountOut;
        s_treasury[_tokenIn] += _amountIn;
        IERC20(_tokenIn).approve(address(this), _amountIn);
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenOut).transferFrom(address(this), msg.sender, amountOut);
        emit Swap(_tokenIn, _tokenOut, _amountIn, amountOut);
    }

    /**
     *  @notice 
     *  @dev 
     */
    function stake(address _token, uint256 _amount) external payable {
        s_stake[msg.sender][_token] += _amount;
        stakeTime = block.timestamp;
        farmed += (block.timestamp - stakeTime)*yield;
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    /**
     *  @notice 
     *  @dev 
     */
    function blindDca(uint256 _deposit, uint256 _amount) external {
        IERC20(i_tokenList[0]).approve(address(this), _deposit);
        s_dca.push(msg.sender);
    }

    /**
     *  @notice This function updates the prices of all tokens
     */
    function _updateTokenPrices() private {
        for (uint256 i; i < i_tokenList.length; i++){
            address token = i_tokenList[i];
            (,int tokenPrice,,,) = (i_tokenToPriceFeed[token]).latestRoundData();
            i_tokenToUsd[token] = uint256(tokenPrice);
        }
    }

    /**
     *  @notice This function updates the daily token for DCA and requests another random token
     */
    function _setDailyToken() private {
        uint256 tokenId = _fulfillRandomWords() + 1;
        s_dailyToken = i_tokenList[tokenId];
    } 


    /**
     *  @dev This function requests a random value to the Chainlink VRF nodes and returns
     *  an ID for that request. To get the random value, a second call to the oracle is
     *  necessary, done through the function fulfillRandomWords()
     */
    function _requestId() 
        private
        returns (uint256 requestId)
    {
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
    function _fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        private
        override
        returns(uint256)
    {
        return (randomWords[0] % 1);
    }

    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > INTERVAL;
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
        lastTimeStamp = block.timestamp;
        for (uint256 i; i < s_dca.length; i++) {
            
        }
        _updateTokenPrices();
        _setDailyToken();
        _requestId();
        performData;
    }
}