require("dotenv").config()
require("@nomiclabs/hardhat-etherscan")
require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("solidity-coverage")
require("hardhat-deploy")

module.exports = {
    solidity: {
        compilers: [
            { version: "0.8.7" },
            { version: "0.8.0" },
            { version: "0.7.0" },
        ],
    },
    defaultNetwork: "hardhat",
    networks: {
        localhost: {
            url: "http://127.0.0.1:8545/",
            chainId: 31337,
        },
        rinkeby: {
            url: process.env.RINKEBY_RPC_URL,
            accounts: [process.env.PRIVATE_KEY],
            chainId: 4,
            blockConfirmations: 5,
        },
        mumbai: {
            url: process.env.MUMBAI_RPC_URL,
            accounts: [process.env.PRIVATE_KEY],
            chainId: 80001,
            blockConfirmations: 5,
        },
        fuji: {
            url: process.env.FUJI_RPC_URL,
            accounts: [process.env.PRIVATE_KEY],
            chainId: 43113,
            blockConfirmations: 5,
        },
        fantomTestnet: {
            url: process.env.FANTOMTESTNET_RPC_URL,
            accounts: [process.env.PRIVATE_KEY],
            chainId: 4002,
            blockConfirmations: 5,
        },
    },
    /* gasReporter: {
        enabled: false,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        coinmarketcap: COINMARKETCAP_API_KEY,
        token: "MATIC",
    }, */
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        user1: {
            default: 1,
        },
        user2: {
            default: 2,
        },
    },
}
