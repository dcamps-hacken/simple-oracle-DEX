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
        it("Should mint initial supply of tokens on deployment", async function () {
            const deployerBalance = await usd.balanceOf(deployer)
            assert.equal(deployerBalance.toString(), initialSupply.toString())
        })
    })
    describe("mint", async function () {
        it("Should mint additional tokens on demand", async function () {
            const mint = await usd.mint(user, "1")
            await mint.wait() // wait until the transaction is mined
            const userBalance = await usd.balanceOf(user)
            assert.equal(userBalance.toString(), minted.toString())
        })
    })
    describe("mint", async function () {
        it("Should burn tokens", async function () {
            const burn = await usd.burn(user, "1")
            await burn.wait() // wait until the transaction is mined
            const newBalance = await elf.balanceOf(user)
            assert.equal(newBalance.toString(), constants.Zero.toString())
        })
    })
})
