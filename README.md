# ORACLE DEX

> ⏳⚠️ This project is currently under construction ⚠️⏳

**Oracle DEX** project consists of a main hybrid [_DEX_](https://github.com/fields93/simple-oracle-DEX/blob/main/contracts/DEX.sol) smart contract containing the all features, and integrating Chainlink's [Data Feeds](https://docs.chain.link/docs/using-chainlink-reference-contracts/), [VRF](https://docs.chain.link/docs/chainlink-vrf/) and [Keepers](https://docs.chain.link/docs/chainlink-keepers/introduction/).

In additional, [_elf_](https://github.com/fields93/simple-oracle-DEX/blob/main/contracts/elf.sol), [_wizard_](https://github.com/fields93/simple-oracle-DEX/blob/main/contracts/wizard.sol) and [_stablecoin_](https://github.com/fields93/simple-oracle-DEX/blob/main/contracts/stablecoin.sol) contracts in this project are used to deploy ERC20 tokens that can be used for testing. Other tokens won't work.

## QUICKSTART 🚀

```git
git clone https://github.com/fields93/simple-oracle-DEX.git
```

## Using the DEX

This **DEX** has 3 different functionalities that can be used with only three test tokens: $USD, $WZD and $ELF.

### 🥇 Swap

This feature allows any user to trade one token for another using the `swap()` method. The conversion rate between any pair of tokens is obtained from Chainlink's [Data Feeds](https://docs.chain.link/docs/using-chainlink-reference-contracts/). Since the three tokens from this DEX have no market value, their value is tied to the following tokens:

-   $USD = $USD
-   $WZD = $ETH
-   $ELF = $BTC

### 🥈 Stake

Using the function `stake()` any user can lock any amount of tokens to obtain a yield. The staked tokens and the rewards can be redeemed at any moment using the method `unstake()`. A fixed 3% APR is generated in the form of the staked tokens.

### 🥉 DCA

In order to avoid market volatility, a user can buy any of the DEX tokens using $USD (therefore only $WZD and $ELF can be bought) in a blind (random) way. The method `setDca()` will approve the [_DEX_](https://github.com/fields93/simple-oracle-DEX/blob/main/contracts/DEX.sol) contract to spend a set amount of USD from the user to buy a random token, determined by the Chainlink's [VRF](https://docs.chain.link/docs/chainlink-vrf/).

Chainlink's [Keepers](https://docs.chain.link/docs/chainlink-keepers/introduction/) is used to trigger the DCA buy orders of all the users at once, every week.
