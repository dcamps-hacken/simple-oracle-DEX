const { expect, assert } = require("chai")
const { BigNumber, constants } = require("ethers")
const { ethers } = require("hardhat")

describe("Wizard", function () {
    let totalSupply = constants.Zero
    const initialSupply = BigNumber.from("10000000000000000000000000000")
    const minted = BigNumber.from("1000000000000000000")
    let deployer, user
    beforeEach(async function () {
        wizard = await ethers.getContract("Wizard")
        deployer = (await getNamedAccounts()).deployer
        user = (await getNamedAccounts()).user1
    })
    describe("constructor", async function () {
        it("Mints initial supply of tokens", async function () {
            const deployerBalance = await wizard.balanceOf(deployer)
            assert.equal(deployerBalance.toString(), initialSupply.toString())
        })
    })
    describe("mint", async function () {
        it("Should mint additional tokens on demand", async function () {
            const userBalance = await wizard.balanceOf(user)
            const mint = await wizard.mint(user, "1")
            await mint.wait() // wait until the transaction is mined
            const newBalance = await wizard.balanceOf(user)
            const calculatedNewBalance = userBalance.add(minted)
            assert.equal(newBalance.toString(), calculatedNewBalance.toString())
        })
    })
})
