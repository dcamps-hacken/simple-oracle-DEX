const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
//const { verify } = require("../utils/verify.js")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer, user1, user2 } = await getNamedAccounts()
    const chainId = network.config.chainId

    let vrfCoordinatorV2Address, subscriptionId, MockV3AggregatorAddress

    if (developmentChains.includes(network.name)) {
        const VRFCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        )
        vrfCoordinatorV2Address = VRFCoordinatorV2Mock.address
        const tx = await VRFCoordinatorV2Mock.createSubscription()
        const txReceipt = await tx.wait(1) // what is this?
        subscriptionId = await txReceipt.events[0].args.subId
        const MockV3Aggregator = await ethers.getContract("MockV3Aggregator")
        MockV3AggregatorAddress = MockV3Aggregator.address
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"]
        subscriptionId = networkConfig[chainId]["subscriptionId"]
        priceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    const args = [
        vrfCoordinatorV2Address,
        subscriptionId,
        networkConfig[chainId]["gasLane"],
        networkConfig[chainId]["callbackGasLimit"],
        MockV3AggregatorAddress,
    ]
    await deploy("PokemonNft", {
        from: deployer,
        args: args,
        log: true,
        AwaitConfirmations: network.config.blockConfirmations || 4,
    })

    //if (
    //    !developmentChains.includes(network.name) &&
    //    process.env.ETHERSCAN_API_KEY
    //) {
    //    log("Verifying...")
    //    await verify(basicNft.address, arguments)
    //}
    //log("--------------------------")
}
module.exports.tags = ["all", "nft"]
