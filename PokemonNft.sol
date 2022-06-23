//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpdsNft__RangeOutOfBounds();

contract PokemonNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    enum Rarity {
        NORMAL,
        RARE,
        MYTHIC
    }

    struct Character {
        uint256 power;
        uint256 health;
        uint256 attack;
        uint256 defense;
        string name;
    }

    Character[] public characters;

    // VRF Helpers
    mapping(uint256 => string) public s_requestToCharacterName;
    mapping(uint256 => address) public s_requestIdToSender;

    AggregatorV3Interface private i_priceFeed;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 3;

    // NFT Variables
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    /* string[] internal s_dogTokenUris; */

    /* Events */
    event characterRequest(uint256 indexed requestId, address requester);

    /* event NftMinted(Breed dogBreed, address minter); */

    constructor(
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        address _priceFeed
    )
        /* string[3] memory _dogTokenUris, */
        VRFConsumerBaseV2(_vrfCoordinatorV2)
        ERC721("PokemonNFT", "PKM")
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_priceFeed = AggregatorV3Interface(_priceFeed);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        /* s_dogTokenUris = _dogTokenUris; */
    }

    function requestCharacter(string memory name)
        public
        payable
        returns (uint256 requestId)
    {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        s_requestToCharacterName[requestId] = name;
        emit characterRequest(requestId, msg.sender);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 newTokenId = characters.length;
        uint256 power = uint256(getLatestPrice() / 1e16);
        uint256 health = randomWords[0] % 100;
        uint256 attack = randomWords[1] % 100;
        uint256 defense = randomWords[2] % 100;
        Character memory character = Character(
            power,
            health,
            attack,
            defense,
            s_requestToCharacterName[requestId]
        );
        characters.push(character);
        _safeMint(s_requestIdToSender[requestId], newTokenId);

        //the caller of this function is a chainlink node, so we cannot use msg.sender as the owner
        /* Breed dogBreed = getBreedFromModdedRng(moddedRng);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);
        emit NftMinted(dogBreed, dogOwner); */
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        return price;
    }

    /* function getBreedFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (Breed)
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i > chanceArray.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + chanceArray[i]
            ) {
                return Breed(i);
            }
            cumulativeSum += chanceArray[i];
        }
        revert RandomIpdsNft__RangeOutOfBounds();
    } */

    /* function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUris(uint256 index)
        public
        view
        returns (string memory)
    {
        return s_dogTokenUris[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    } */
}
