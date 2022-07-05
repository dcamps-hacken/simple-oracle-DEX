const { expect, assert } = require("chai")
const { ethers, getNamedAccounts, deployments } = require("hardhat")
const { BigNumber, constants } = require("ethers")

describe("DEX", function () {
    const tokens = [usd, wzd, elf]
    const mint = "1000000"
    beforeEach(async function () {
        const { deployer, user1, user2 } = await getNamedAccounts()
        //await deployments.fixture(["all"])
        dex = await ethers.getContract("DEX", deployer)
    })
    describe("constructor", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("swap", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("stake", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("unstake", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("performUpkeep", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("addTreasury", function () {
        beforeEach(async function () {
            let initialBalance, newBalance, mint
        })
        it("adds test tokens to the DEX", async function () {
            for (let token of tokens) {
                initialBalance = await dex.getTreasury(token)
                mint = await dex.addTreasury(token, mint)
                await mint.wait()
                newBalance = await dex.getTreasury(token)
                expect(initialBalance).to.equal(newBalance)
            }
        })
    })
    describe("checkUpkeep", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("fulfillRandomWords", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("_buyDca", function () {
        beforeEach(async function () {
            543
            let swapAmount
            token = tokens[0]
        })
        it("throws error if users try to withdraw more tokens than they own", async function () {
            swapAmount = "10000000000000000000000000000000"
            await dex._buyDCA()
        })
        it("throws error if users try to withdraw more tokens than the DEX owns", async function () {
            await dex._buyDCA()
        })
        it("swaps test USD for a random token between WZD and ELF", async function () {
            const initialBalance = await dex.getBalance(user1, token)
            const initialTreasury = await dex.getTreasury(token)
            const swap = await dex._buyDCA()
            await swap.wait()
            const newBalance = await dex.getBalance(user1, token)
            const newTreasury = await dex.getTreasury(token)
        })
    })
    describe("_updateTokenPrices", function () {
        beforeEach(async function () {
            let initialPrice, newPrice, priceSum
        })
        it("updates the prices of every token", async function () {
            for (let token of tokens) {
                initialPrice = await dex.getTokenPrice(token)
                //getDataFeed price
                newPrice = await dex.getTokenPrice(token)
                priceSum = initialPrice.add(newPrice)
                //how to check data feed price
            }
        })
    })
    describe("_requestId", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("getTokenPrice", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
    describe("getDailyToken", function () {
        beforeEach(async function () {})
        it("", async function () {})
    })
})
