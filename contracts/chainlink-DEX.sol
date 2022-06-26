//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

    /* VRF */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    /* Data Feeds */
    string[] private constant TOKENS = ["ETH", "BTC", "MATIC"];
    mapping (string => uint256) private immutable i_tokenToUsd;
    mapping (string => AggregatorV3Interface) private immutable i_tokenToPriceFeed;
    

    /* Staking */
    mapping (address => mapping (address => uint256)) s_staked;

    Event Swap(address input, address output, amount);
    Event PriceUpdate(address token, uint256 newPrice);


    constructor(
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        address _ethUsdPriceFeed,
        address _btcUsdtPriceFeed,
        address _maticUsdPriceFeed
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
     *  @notice 
     *  @dev 
     */
    function buy(string memory _token, uint256 _usd) external {
        //transferFrom(_usd)
        msg.sender.transfer(1/i_tokenToUsd);
        emit Swap(_input, _output, _amount);
    }

    /**
     *  @notice 
     *  @dev 
     */
    function stake(address _input, uint256 _amount) external payable {
        s_stake[msg.sender][_input] += _amount;
    }

    /**
     *  @notice 
     *  @dev 
     */
    function dca(uint256 _amount) external {} 

    function updatePrices() external {
        for (uint256 i; i < TOKENS.length; i++){
            string memory token = TOKENS[i];
            uint256 newPrice = uint256(_updatePrice(i_tokenToPriceFeed[token]);
            i_tokenToUsd[token] = newPrice;
        }
    }

    function _updatePrice(AggregatorV3Interface _priceFeed) private returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = _priceFeed.latestRoundData();
        return price;
    }

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

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        randomWords[0] % 2;
    }
}
