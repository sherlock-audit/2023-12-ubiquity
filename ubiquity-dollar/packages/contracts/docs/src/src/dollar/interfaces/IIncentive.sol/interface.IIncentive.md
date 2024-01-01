# IIncentive
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/cbd28a4612a3e634eb46789c9d7030bc45955983/src/dollar/interfaces/IIncentive.sol)

Incentive contract interface

Called by Ubiquity Dollar token contract when transferring with an incentivized address.
Dollar admin can set an incentive contract for a partner in order to, for example, mint partner's
project tokens on Dollars transfers. Incentive contracts can be set for the following transfer operations:
- EOA => contract
- contract => EOA
- contract => contract
- any transfer incentive contract

*Should be appointed as a Minter or Burner as needed*


## Functions
### incentivize

Applies incentives on transfer


```solidity
function incentivize(address sender, address receiver, address operator, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|the sender address of Ubiquity Dollar|
|`receiver`|`address`|the receiver address of Ubiquity Dollar|
|`operator`|`address`|the operator (msg.sender) of the transfer|
|`amount`|`uint256`|the amount of Ubiquity Dollar transferred|


