const { expect, assert } = require("chai")
const { BigNumber, constants } = require("ethers")
const { ethers } = require("hardhat")

describe("Elf", function () {
    let totalSupply = constants.Zero
    const initialSupply = BigNumber.from("10000000000000000000000000000")
    const minted = BigNumber.from("1000000000000000000")
    let deployer, user
    beforeEach(async function () {
        elf = await ethers.getContract("Elf")
        deployer = (await getNamedAccounts()).deployer
        user = (await getNamedAccounts()).user1
    })
    describe("constructor", async function () {
        it("Should mint initial supply of tokens on deployment", async function () {
            const deployerBalance = await elf.balanceOf(deployer)
            assert.equal(deployerBalance.toString(), initialSupply.toString())
        })
    })
    describe("mint", async function () {
        it("Should mint additional tokens on demand", async function () {
            const mint = await elf.mint(user, "1")
            await mint.wait() // wait until the transaction is mined
            const userBalance = await elf.balanceOf(user)
            assert.equal(userBalance.toString(), minted.toString())
        })
    })
})
