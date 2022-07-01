const { expect, assert } = require("chai")
const { ethers } = require("hardhat")

describe("ERC20", function () {
    const initialMint = "10000000000000000000000000000"
    const mintAmount = "1000000000000000000000"
    let deployer
    beforeEach(async function () {
        wizard = await ethers.getContract("Wizard")
        deployer = (await getNamedAccounts()).deployer
    })
    describe("constructor", async function () {
        it("Should mint initial supply of tokens on deployment", async function () {
            const supply = await wizard.totalSupply()
            assert.equal(supply, initialMint)
        })
    })
    describe("mint", async function () {
        it("Should mint additional tokens on demand", async function () {
            const mint = await wizard.mint(deployer, mintAmount)
            // wait until the transaction is mined
            await mint.wait()
            const newSupply = (await wizard.totalSupply()).toString()
            //assert.equal(newSupply, calculatedSupply)
        })
    })
})
