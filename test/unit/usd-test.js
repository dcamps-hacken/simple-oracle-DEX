const { expect, assert } = require("chai")
const { BigNumber, constants } = require("ethers")
const { ethers } = require("hardhat")

describe("StableCoin", function () {
    let totalSupply = constants.Zero
    const initialSupply = BigNumber.from("10000000000000000000000000000")
    const minted = BigNumber.from("1000000000000000000")
    let deployer, user
    beforeEach(async function () {
        usd = await ethers.getContract("StableCoin")
        deployer = (await getNamedAccounts()).deployer
        user = (await getNamedAccounts()).user1
    })
    describe("constructor", async function () {
        it("Mints initial supply of tokens", async function () {
            const deployerBalance = await usd.balanceOf(deployer)
            assert.equal(deployerBalance.toString(), initialSupply.toString())
        })
    })
    describe("mint", async function () {
        it("Should mint additional tokens on demand", async function () {
            const userBalance = await usd.balanceOf(user)
            const mint = await usd.mint(user, "1")
            await mint.wait() // wait until the transaction is mined
            const newBalance = await usd.balanceOf(user)
            const calculatedNewBalance = userBalance.add(minted)
            assert.equal(newBalance.toString(), calculatedNewBalance.toString())
        })
    })
})
