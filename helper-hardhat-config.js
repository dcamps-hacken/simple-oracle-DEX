const networkConfig = {
    31337: {
        name: "localhost",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        callbackGasLimit: "200000",
    },
    4: {
        // premium = 0.25 LINK
        name: "rinkeby",
        usd: "0x81f7f9be026841b133bfF7F96EC97c330048E38b",
        wzd: "0x15329cB93f68EF6431Ca449710eCACf32B9f0B26",
        elf: "",
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
        btcUsdPriceFeed: "0xECe365B379E1dD183B20fc5f022230C044d51404",
        vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        callbackGasLimit: "200000",
    },
    80001: {
        //premium = 0.0005 LINK
        name: "mumbai",
        usd: "0x021EdbAc1699F3c9d7550946c3bCBb3D81Dff43c",
        wzd: "0x5fEa889B4193A74F8cCf28bcc629ac32c0a83F0F",
        elf: "",
        ethUsdPriceFeed: "0x0715A7794a1dc8e42615F059dD6e406A6594651A",
        btcUsdPriceFeed: "0x007A22900a3B98143368Bd5906f8E17e9867581b",
        vrfCoordinatorV2: "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed",
        gasLane:
            "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f",
        callbackGasLimit: "200000",
    },
    43113: {
        //premium = 0.005 LINK
        name: "fuji",
        ethUsdPriceFeed: "0x86d67c3D38D2bCeE722E601025C25a575021c6EA",
        btcUsdPriceFeed: "0x31CF013A08c6Ac228C94551d535d5BAfE19c602a",
        vrfCoordinatorV2: "0x2eD832Ba664535e5886b75D64C46EB9a228C2610",
        gasLane:
            "0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61",
        callbackGasLimit: "200000",
    },
    4002: {
        //premium = 0.0005 LINK
        name: "fantom-testnet",
        ethUsdPriceFeed: "0xB8C458C957a6e6ca7Cc53eD95bEA548c52AFaA24",
        btcUsdPriceFeed: "0x65E8d79f3e8e36fE48eC31A2ae935e92F5bBF529",
        vrfCoordinatorV2: "0xbd13f08b8352A3635218ab9418E340c60d6Eb418",
        gasLane:
            "0x121a143066e0f2f08b620784af77cccb35c6242460b4a8ee251b4b416abaebd4",
        callbackGasLimit: "200000",
    },
}

const developmentChains = ["hardhat", "localhost"]
const DECIMALS = 8
const INITIAL_ANSWER = 200000000000

module.exports = {
    networkConfig,
    developmentChains,
    DECIMALS,
    INITIAL_ANSWER,
}
