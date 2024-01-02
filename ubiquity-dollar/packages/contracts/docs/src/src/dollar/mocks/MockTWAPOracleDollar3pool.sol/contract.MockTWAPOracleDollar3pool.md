# MockTWAPOracleDollar3pool
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/940040226cc8480b0e7aa65d1592259dfcf013ef/src/dollar/mocks/MockTWAPOracleDollar3pool.sol)


## State Variables
### pool

```solidity
address public immutable pool;
```


### token0

```solidity
address public immutable token0;
```


### token1

```solidity
address public immutable token1;
```


### price0Average

```solidity
uint256 public price0Average;
```


### price1Average

```solidity
uint256 public price1Average;
```


### pricesBlockTimestampLast

```solidity
uint256 public pricesBlockTimestampLast;
```


### priceCumulativeLast

```solidity
uint256[2] public priceCumulativeLast;
```


## Functions
### constructor


```solidity
constructor(
    address _pool,
    address _dollarToken0,
    address _curve3CRVToken1,
    uint256 _price0Average,
    uint256 _price1Average
);
```

### consult


```solidity
function consult(address token) external view returns (uint256 amountOut);
```

### update


```solidity
function update() external pure;
```

