const { run, network } = require("hardhat")
const hre = require("hardhat")

async function main() {
    // DEPLOY CONTRACT
    const SampleFactory = await hre.ethers.getContractFactory("Sample.sol")
    const sample = await SampleFactory.deploy()
    await sample.deployed()

    console.log(network.config) // will show chainId of Hardhat network

    // now we can use a selector for only rinkeby and also if we have the API keys,
    // since the verification would not work for the hardhat local network
    if (network.config.chainId === 4 && process.env.ETHERSCAN_API_KEY) {
        //we wait 6 blocks to run the verification so that etherscan had time to update
        await sample.deployTransaction.wait(6)
        await verify(sample.address, []) //[] is an empty array, for possible constructor args
    }
}

async function verify(contractAddress, args) {
    // constructor arguments must be specified in args
    console.log("Verifying contract...")
    try {
        //we use try-cath bc sometimes it says the contract is already verified
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        //we use a try-cath approach so that the script doesn't stop if it gets an error
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!")
        } else {
            console.log(e)
        }
    }
}

// Call the main function
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
