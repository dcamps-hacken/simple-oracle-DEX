//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* This contract allows to swap between 4 coins, tied to different data feeds:
    1) ETH
    2) USD (USDT)
    3) WZD (LINK)
    4) ELF (Polygon)
*/

/* Every day, chainlink keepers will update the prices of these assets, 
    combined with data feeds, and store them in this contract 
*/

/* The user can swap the tokens they want or automatize a random buy */

contract DEX is VRFConsumerBaseV2, Ownable {
    
    /* Prices */
    address[] constant TOKENRATES;
    mapping (address => mapping (address => uint256)) s_prices;
    mapping (address => mapping (address => uint256)) s_stake;

    Event Swap(address input, address output, amount);

    /* Data Feeds */
    AggregatorV3Interface private immutable i_priceFeed;
    
    /* VRF */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 3;

    constructor(
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        address _priceFeed
    )
        VRFConsumerBaseV2(_vrfCoordinatorV2)
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_priceFeed = AggregatorV3Interface(_priceFeed);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
    }

    function swap(address _input, address _output, uint256 _amount) external payable {
        if(msg.value != 0) {
            _amount = msg.value;
        }
        conversionRate = s_prices[_input][_output];
        outputAmount = _amount*conversionRate;
        msg.sender.transfer(outputAmount);
        emit Swap(_input, _output, _amount);
    }

    function stake(address _input, uint256 _amount) external payable {
        s_stake[msg.sender][_input] += _amount;
    }

    function requestId()
        public
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
        randomWords[2] % 100;
    }

    function updatePrices(address _token1, address _token2) private {
        uint256 numberOfTokens = TOKENRATES.length;
        for (uint256 i; i < numberOfTokens; i++){
            _updatePrice(_token1, _token2, newPrice);
        }
    }

    function _updatePrice(address _token1, address _token2, uint256 _newPrice) private {
        uint256 newPrice = uint256(getLatestPrice() / 1e16); //decimals correct?
        s_prices[_token1][_token2] = newPrice;
    }
}
