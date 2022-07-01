const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify.js")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const usd = await deploy("StableCoin", {
        from: deployer,
        log: true,
        args: [],
        AwaitConfirmations: network.config.blockConfirmations || 5,
    })

    const wizard = await deploy("Wizard", {
        from: deployer,
        log: true,
        args: [],
        AwaitConfirmations: network.config.blockConfirmations || 5,
    })

    const elf = await deploy("Elf", {
        from: deployer,
        log: true,
        args: [],
        AwaitConfirmations: network.config.blockConfirmations || 5,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying...")
        await verify(usd.address, arguments)
        await verify(wzd.address)
        await verify(elf.address, arguments)
    }
    log("--------------------------")
}
