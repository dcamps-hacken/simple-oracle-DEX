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
 *      - Swap coins
 *      - Stake coins
 *      - DCA into coins
 *  Only 4 coins can be used:
 *      - USD
 *      - ETH
 *      - WZD
 *      - ELF
 */

contract DEX is VRFConsumerBaseV2, Ownable {

    struct Token {
        uint128 price;
        uint128 treasury;
        AggregatorV3Interface priceFeed;
    }

    /* VRF */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    /* Data Feeds */
    address[] private immutable i_tokenList;
    mapping (address => Token) s_tokens;
    

    /* Staking */
    mapping (address => mapping (address => uint256)) s_staked;

    /* DCA */
    address private s_dailyToken;

    Event Swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    Event PriceUpdate(address token, uint256 newPrice);


    constructor(
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        address _ethUsdPriceFeed,
        address _btcUsdtPriceFeed,
        address _maticUsdPriceFeed,
        address[] _tokens
    )
        VRFConsumerBaseV2(_vrfCoordinatorV2)
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        i_ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        i_btcUsdPriceFeed = AggregatorV3Interface(_btcUsdtPriceFeed);
        i_maticUsdPriceFeed = AggregatorV3Interface(_maticUsdPriceFeed);
    }

    /**
     *  @notice This function allows to swap any pair of tokens
     *  @dev 
     */
    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn) external {
        //corner cases of ETH and USD!!!
        uint256 amountOut = _amountIn*(i_tokenToUsd[_tokenOut]/i_tokenToUsd[_tokenIn]);
        s_treasury[_tokenOut] -= amountOut;
        s_treasury[_tokenIn] += _amountIn;
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenOut).transferFrom(address(this), msg.sender, amountOut);
        msg.sender.transfer(1/i_tokenToUsd);
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
    function blindDca(uint256 _amount) external {} 

    /**
     *  @notice This function updates the prices of all tokens
     */
    function updateTokenPrices() external {
        for (uint256 i; i < i_tokens.length; i++){
            address token = i_tokens[i];
            (,int tokenPrice,,,) = (i_tokenToPriceFeed[token]).latestRoundData();
            i_tokenToUsd[token] = uint256(tokenPrice);
        }
    }

    /**
     *  @notice This function updates the daily token for DCA and requests another random token
     */
    function setDailyToken() external {
        uint256 tokenId = fulfillRandomWords();
        s_dailyToken = i_tokens[tokenId];
        requestId();
    } 


    /**
     *  @dev This function requests a random value to the Chainlink VRF nodes and returns
     *  an ID for that request. To get the random value, a second call to the oracle is 
     *  necessary, done through the function fulfillRandomWords()
     */
    function requestId() 
        external
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
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
        returns(uint256)
    {
        return (randomWords[0] % 2);
    }
}
