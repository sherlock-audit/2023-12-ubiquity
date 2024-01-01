# BondingCurveFacet
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/cbd28a4612a3e634eb46789c9d7030bc45955983/src/dollar/facets/BondingCurveFacet.sol)

**Inherits:**
[Modifiers](/src/dollar/libraries/LibAppStorage.sol/contract.Modifiers.md), [IBondingCurve](/src/dollar/interfaces/IBondingCurve.sol/interface.IBondingCurve.md)

Bonding curve contract based on Bancor formula

Inspired from Bancor protocol https://github.com/bancorprotocol/contracts

Used on UbiquiStick NFT minting


## Functions
### setParams

Sets bonding curve params


```solidity
function setParams(uint32 _connectorWeight, uint256 _baseY) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_connectorWeight`|`uint32`|Connector weight|
|`_baseY`|`uint256`|Base Y|


### connectorWeight

Returns `connectorWeight` value


```solidity
function connectorWeight() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Connector weight value|


### baseY

Returns `baseY` value


```solidity
function baseY() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Base Y value|


### poolBalance

Returns total balance of deposited collateral


```solidity
function poolBalance() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of deposited collateral|


### deposit

Deposits collateral tokens in exchange for UbiquiStick NFT


```solidity
function deposit(uint256 _collateralDeposited, address _recipient) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_collateralDeposited`|`uint256`|Amount of collateral|
|`_recipient`|`address`|Address to receive the NFT|


### getShare

Returns number of NFTs a `_recipient` holds


```solidity
function getShare(address _recipient) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|User address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of NFTs for `_recipient`|


### withdraw

Withdraws collateral tokens to treasury


```solidity
function withdraw(uint256 _amount) external onlyAdmin whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|Amount of collateral tokens to withdraw|


### purchaseTargetAmount

Given a token supply, reserve balance, weight and a deposit amount (in the reserve token),
calculates the target amount for a given conversion (in the main token)

`_supply * ((1 + _tokensDeposited / _connectorBalance) ^ (_connectorWeight / 1000000) - 1)`


```solidity
function purchaseTargetAmount(
    uint256 _tokensDeposited,
    uint32 _connectorWeight,
    uint256 _supply,
    uint256 _connectorBalance
) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokensDeposited`|`uint256`|Amount of collateral tokens to deposit|
|`_connectorWeight`|`uint32`|Connector weight, represented in ppm, 1 - 1,000,000|
|`_supply`|`uint256`|Current token supply|
|`_connectorBalance`|`uint256`|Total connector balance|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of tokens minted|


### purchaseTargetAmountFromZero

Given a deposit (in the collateral token) token supply of 0, calculates the return
for a given conversion (in the token)

`_supply * ((1 + _tokensDeposited / _connectorBalance) ^ (_connectorWeight / 1000000) - 1)`


```solidity
function purchaseTargetAmountFromZero(
    uint256 _tokensDeposited,
    uint256 _connectorWeight,
    uint256 _baseX,
    uint256 _baseY
) external pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokensDeposited`|`uint256`|Amount of collateral tokens to deposit|
|`_connectorWeight`|`uint256`|Connector weight, represented in ppm, 1 - 1,000,000|
|`_baseX`|`uint256`|Constant x|
|`_baseY`|`uint256`|Expected price|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Amount of tokens minted|


