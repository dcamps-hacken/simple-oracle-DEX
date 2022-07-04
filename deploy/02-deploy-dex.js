const { verify } = require("../utils/verify.js")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const dex = await deploy("DEX", {
        from: deployer,
        args: [],
        log: true,
    })
}
