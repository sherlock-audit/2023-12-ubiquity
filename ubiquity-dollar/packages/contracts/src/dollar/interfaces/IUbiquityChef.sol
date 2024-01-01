// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol. SEE BELOW FOR SOURCE. !!
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @notice Interface for staking Dollar-3CRV LP tokens for Governance tokens reward
 */
interface IUbiquityChef {
    /// @notice User's staking share info
    struct StakingShareInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    /// @notice Pool info
    struct PoolInfo {
        uint256 lastRewardBlock; // Last block number that Governance Token distribution occurs.
        uint256 accGovernancePerShare; // Accumulated Governance Token per share, times 1e12. See below.
    }

    /// @notice Emitted when Dollar-3CRV LP tokens are deposited to the contract
    event Deposit(address indexed user, uint256 amount, uint256 stakingShareID);

    /// @notice Emitted when Dollar-3CRV LP tokens are withdrawn from the contract
    event Withdraw(
        address indexed user,
        uint256 amount,
        uint256 stakingShareID
    );

    /**
     * @notice Deposits Dollar-3CRV LP tokens to staking for Governance tokens allocation
     * @param sender Address where to transfer pending Governance token rewards
     * @param amount Amount of LP tokens to deposit
     * @param stakingShareID Staking share id
     */
    function deposit(
        address sender,
        uint256 amount,
        uint256 stakingShareID
    ) external;

    /**
     * @notice Withdraws Dollar-3CRV LP tokens from staking
     * @param sender Address where to transfer pending Governance token rewards
     * @param amount Amount of LP tokens to withdraw
     * @param stakingShareID Staking share id
     */
    function withdraw(
        address sender,
        uint256 amount,
        uint256 stakingShareID
    ) external;

    /**
     * @notice Returns staking share info
     * @param _id Staking share id
     * @return Array of amount of shares and reward debt
     */
    function getStakingShareInfo(
        uint256 _id
    ) external view returns (uint256[2] memory);

    /**
     * @notice Total amount of Dollar-3CRV LP tokens deposited to the Staking contract
     * @return Total amount of deposited LP tokens
     */
    function totalShares() external view returns (uint256);

    /**
     * @notice Returns amount of pending reward Governance tokens
     * @param _user User address
     * @return Amount of pending reward Governance tokens
     */
    function pendingGovernance(address _user) external view returns (uint256);
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON: