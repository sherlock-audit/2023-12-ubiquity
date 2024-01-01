// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../../src/dollar/mocks/MockERC20.sol";
import {IERC20Ubiquity} from "../../../src/dollar/interfaces/IERC20Ubiquity.sol";
import {IERC1155Ubiquity} from "../../../src/dollar/interfaces/IERC1155Ubiquity.sol";
import {IUbiquityDollarManager} from "../../../src/dollar/interfaces/IUbiquityDollarManager.sol";
import {DirectGovernanceFarmerFacet} from "../../../src/dollar/facets/DirectGovernanceFarmerFacet.sol";
import "../DiamondTestSetup.sol";
import "../../../src/dollar/interfaces/IStableSwap3Pool.sol";
import "../../../src/dollar/interfaces/IStaking.sol";
import "../../../src/dollar/interfaces/IStakingShare.sol";
import "../../../src/dollar/interfaces/IDepositZap.sol";

contract DirectGovernanceFarmerFacetTest is DiamondTestSetup {
    // DAI
    MockERC20 token0;
    // USDC
    MockERC20 token1;
    // USDT
    MockERC20 token2;

    IERC20Ubiquity dollar;

    MockERC20 stableSwapMetaPool;
    address dollarManagerAddress;
    address depositZapAddress = address(0x4);
    address base3PoolAddress = address(0x5);

    event DepositSingle(
        address indexed sender,
        address token,
        uint256 amount,
        uint256 durationWeeks,
        uint256 stakingShareId
    );
    event DepositMulti(
        address indexed sender,
        uint256[4] amount,
        uint256 durationWeeks,
        uint256 stakingShareId
    );
    event WithdrawAll(
        address indexed sender,
        uint256 stakingShareId,
        uint256[4] amounts
    );

    function setUp() public override {
        super.setUp();

        vm.startPrank(admin);
        dollarManagerAddress = address(diamond);

        dollar = IERC20Ubiquity(
            IUbiquityDollarManager(dollarManagerAddress).dollarTokenAddress()
        );

        // deploy mocked tokens
        token0 = new MockERC20("DAI", "DAI", 18);
        token1 = new MockERC20("USDC", "USDC", 6);
        token2 = new MockERC20("USDT", "USDT", 6);
        // deploy stable swap meta pool
        stableSwapMetaPool = new MockERC20(
            "Stable swap meta pool token",
            "Stable swap meta pool token",
            18
        );

        IUbiquityDollarManager(address(diamond)).setStableSwapMetaPoolAddress(
            address(stableSwapMetaPool)
        );

        IUbiquityDollarManager(address(diamond)).setStakingContractAddress(
            address(0x50)
        );

        // mock base3Pool to return mocked token addresses
        vm.mockCall(
            base3PoolAddress,
            abi.encodeWithSelector(IStableSwap3Pool.coins.selector, 0),
            abi.encode(token0)
        );
        vm.mockCall(
            base3PoolAddress,
            abi.encodeWithSelector(IStableSwap3Pool.coins.selector, 1),
            abi.encode(token1)
        );
        vm.mockCall(
            base3PoolAddress,
            abi.encodeWithSelector(IStableSwap3Pool.coins.selector, 2),
            abi.encode(token2)
        );

        directGovernanceFarmerFacet.initialize(
            address(diamond),
            address(base3PoolAddress),
            address(stableSwapMetaPool),
            address(dollar),
            address(depositZapAddress)
        );

        vm.stopPrank();
    }

    function test_ShouldMint() public {
        vm.prank(admin);
        dollar.mint(user1, 100e18);
    }

    function testDeposit_ShouldRevert_IfAmountIsNotPositive() public {
        address userAddress = address(0x100);
        vm.prank(userAddress);
        vm.expectRevert("amount must be positive value");
        directGovernanceFarmerFacet.depositSingle(address(token0), 0, 1);
    }

    function test_Should_DebugMockCall_And_Return_Selector() public {
        vm.mockCall(
            base3PoolAddress,
            abi.encodeWithSelector(IStableSwap3Pool.coins.selector),
            abi.encode(token2)
        );
    }

    function testIsMetaPoolCoinReturnTrueIfToken0IsPassed() public {
        assertTrue(directGovernanceFarmerFacet.isMetaPoolCoin(address(token0)));
    }

    function testIsMetaPoolCoinReturnTrueIfToken1IsPassed() public {
        assertTrue(directGovernanceFarmerFacet.isMetaPoolCoin(address(token1)));
    }

    function testIsMetaPoolCoinReturnTrueIfToken2IsPassed() public {
        assertTrue(directGovernanceFarmerFacet.isMetaPoolCoin(address(token2)));
    }

    function testIsMetaPoolCoinReturnTrueIfUbiquityDollarTokenIsPassed()
        public
    {
        assertTrue(directGovernanceFarmerFacet.isMetaPoolCoin(address(dollar)));
    }

    function testIsMetaPoolCoinReturnFalseIfTokenAddressIsNotInMetaPool()
        public
    {
        assertFalse(directGovernanceFarmerFacet.isMetaPoolCoin(address(0)));
    }

    function test_Address() public view returns (address) {
        return address(this);
    }

    function test_IsMetaPoolCoin() public view {
        directGovernanceFarmerFacet.isMetaPoolCoin(address(0x2));
    }

    function testDeposit_ShouldRevert_IfTokenIsNotInMetapool() public {
        address userAddress = address(0x100);
        vm.prank(userAddress);
        vm.expectRevert(
            "Invalid token: must be DAI, USD Coin, Tether, or Ubiquity Dollar"
        );
        directGovernanceFarmerFacet.depositSingle(address(0x250), 1, 1);
    }

    function testDeposit_ShouldRevert_IfDurationIsNotValid() public {
        address userAddress = address(0x100);
        vm.prank(userAddress);
        vm.expectRevert("duration weeks must be between 1 and 208");
        directGovernanceFarmerFacet.depositSingle(address(token1), 1, 0);
    }

    function testWithdrawShouldRevertIfTokenIsNotInMetaPool() public {
        address userAddress = address(0x100);
        vm.prank(userAddress);
        vm.expectRevert(
            "Invalid token: must be DAI, USD Coin, Tether, or Ubiquity Dollar"
        );
        directGovernanceFarmerFacet.withdraw(1, address(0));
    }

    function testDepositMultipleTokens_ShouldRevert_IfAmountsIsNotPositive()
        public
    {
        address userAddress = address(0x100);
        vm.prank(userAddress);
        vm.expectRevert("amounts==0");
        directGovernanceFarmerFacet.depositMulti(
            [uint256(0), uint256(0), uint256(0), uint256(0)],
            1
        );
    }

    function testDepositMultipleTokens_ShouldRevert_IfDurationIsNotValid()
        public
    {
        address userAddress = address(0x100);
        vm.prank(userAddress);
        vm.expectRevert("duration weeks must be between 1 and 208");
        directGovernanceFarmerFacet.depositMulti(
            [uint256(1), uint256(0), uint256(0), uint256(0)],
            0
        );
    }

    function testWithdrawMultiple_ShouldRevert_IfSenderIsNotBondOwner() public {
        address userAddress = address(0x100);
        address stakingShareAddress = address(0x102);

        // admin sets staking share addresses
        vm.prank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );

        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSelector(IERC1155Ubiquity.holderTokens.selector),
            abi.encode([0])
        );

        vm.prank(userAddress);
        vm.expectRevert("!bond owner");
        directGovernanceFarmerFacet.withdrawId(1);
    }

    function testWithdrawShouldRevertIfSenderIsNotBondOwner() public {
        address userAddress = address(0x100);
        address stakingShareAddress = address(0x102);

        // admin sets staking share addresses
        vm.prank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );

        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSelector(IERC1155Ubiquity.holderTokens.selector),
            abi.encode([0])
        );

        vm.prank(userAddress);
        vm.expectRevert("sender is not true bond owner");
        directGovernanceFarmerFacet.withdraw(1, address(token0));
    }

    function testDeposit_ShouldDepositTokens() public {
        address userAddress = address(0x100);
        address stakingAddress = address(0x101);
        address stakingShareAddress = address(0x102);

        // admin sets staking and staking share addresses
        vm.startPrank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingContractAddress(
            stakingAddress
        );
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );
        vm.stopPrank();

        vm.startPrank(userAddress);

        // mint 100 DAI to user
        token0.mint(userAddress, 100e18);
        // user allows DirectGovernanceFarmerHarness to spend user's DAI
        token0.approve(address(directGovernanceFarmerFacet), 100e18);

        // prepare mocks
        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(IDepositZap.add_liquidity.selector),
            abi.encode(100e18)
        );
        vm.mockCall(
            stakingAddress,
            abi.encodeWithSelector(IStaking.deposit.selector),
            abi.encode(1)
        );
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                address(directGovernanceFarmerFacet),
                userAddress,
                1,
                1,
                "0x"
            ),
            ""
        );

        vm.expectEmit(
            true,
            true,
            true,
            true,
            address(directGovernanceFarmerFacet)
        );
        emit DepositSingle(userAddress, address(token0), uint256(100e18), 1, 1);
        // user deposits 100 DAI for 1 week
        uint256 stakingShareId = directGovernanceFarmerFacet.depositSingle(
            address(token0),
            uint256(100e18),
            1
        );
        assertEq(stakingShareId, 1);
    }

    // Multiple

    function testDepositMultipleTokens_ShouldDepositTokens() public {
        address userAddress = address(0x100);
        address stakingAddress = address(0x101);
        address stakingShareAddress = address(0x102);

        // admin sets staking and staking share addresses
        vm.startPrank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingContractAddress(
            stakingAddress
        );
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );
        vm.stopPrank();

        // mint 100 Dollars to user
        vm.startPrank(admin);
        dollar.mint(userAddress, 99e18);
        vm.stopPrank();

        vm.startPrank(userAddress);
        // user allows DirectGovernanceFarmerHarness to spend user's Dollars
        dollar.approve(address(directGovernanceFarmerFacet), 99e18);
        assertEq(dollar.balanceOf(userAddress), 99e18);
        // mint 100 DAI to user
        token0.mint(userAddress, 99e18);
        // user allows DirectGovernanceFarmerHarness to spend user's DAI
        token0.approve(address(directGovernanceFarmerFacet), 99e18);
        assertEq(token0.balanceOf(userAddress), 99e18);
        // mint 100 USDC to user
        token1.mint(userAddress, 98e18);
        // user allows DirectGovernanceFarmerHarness to spend user's USDC
        token1.approve(address(directGovernanceFarmerFacet), 98e18);
        assertEq(token1.balanceOf(userAddress), 98e18);
        // mint 100 USDT to user
        token2.mint(userAddress, 97e18);
        // user allows DirectGovernanceFarmerHarness to spend user's USDT
        token2.approve(address(directGovernanceFarmerFacet), 97e18);
        assertEq(token2.balanceOf(userAddress), 97e18);

        // prepare mocks
        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(
                IDepositZap.add_liquidity.selector,
                address(stableSwapMetaPool),
                [
                    uint256(99e18),
                    uint256(99e18),
                    uint256(98e18),
                    uint256(97e18)
                ],
                0
            ),
            abi.encode(42e18)
        );
        vm.mockCall(
            stakingAddress,
            abi.encodeWithSelector(IStaking.deposit.selector, 42e18, 8),
            abi.encode(12)
        );
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                address(directGovernanceFarmerFacet),
                userAddress,
                12,
                1,
                "0x"
            ),
            ""
        );

        vm.expectEmit(
            true,
            true,
            true,
            true,
            address(directGovernanceFarmerFacet)
        );
        emit DepositMulti(
            userAddress,
            [uint256(99e18), uint256(99e18), uint256(98e18), uint256(97e18)],
            8,
            12
        );

        // user deposits 100 Dollars 99 DAI 98 USDC 97 USDT
        uint256 stakingShareId = directGovernanceFarmerFacet.depositMulti(
            [uint256(99e18), uint256(99e18), uint256(98e18), uint256(97e18)],
            8
        );
        assertEq(stakingShareId, 12);
        assertEq(dollar.balanceOf(userAddress), 0);
        assertEq(token0.balanceOf(userAddress), 0);
        assertEq(token1.balanceOf(userAddress), 0);
        assertEq(token2.balanceOf(userAddress), 0);
    }

    function test_WithdrawShouldWithdraw() public {
        address userAddress = address(0x100);
        address stakingAddress = address(0x101);
        address stakingShareAddress = address(0x102);

        // admin sets staking and staking share addresses
        vm.startPrank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingContractAddress(
            stakingAddress
        );
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );
        vm.stopPrank();

        vm.startPrank(userAddress);

        // mint 100 DAI to user
        token0.mint(userAddress, 100e18);
        // user allows DirectGovernanceFarmerHarness to spend user's DAI
        token0.approve(address(directGovernanceFarmerFacet), 100e18);

        // prepare mocks for deposit
        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(IDepositZap.add_liquidity.selector),
            abi.encode(100e18)
        );
        vm.mockCall(
            stakingAddress,
            abi.encodeWithSelector(IStaking.deposit.selector),
            abi.encode(1)
        );
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                address(directGovernanceFarmerFacet),
                userAddress,
                1,
                1,
                "0x"
            ),
            ""
        );

        // user deposits 100 DAI for 1 week
        directGovernanceFarmerFacet.depositSingle(address(token0), 100e18, 1);

        // wait 1 week + 1 day
        vm.warp(block.timestamp + 8 days);

        // prepare mocks for withdraw
        uint256[] memory stakingShareIds = new uint256[](1);
        stakingShareIds[0] = 1;
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSelector(IERC1155Ubiquity.holderTokens.selector),
            abi.encode(stakingShareIds)
        );

        IStakingShare.Stake memory stake;
        stake.lpAmount = 100e18;
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSelector(IStakingShare.getStake.selector),
            abi.encode(stake)
        );

        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(
                IDepositZap.remove_liquidity_one_coin.selector
            ),
            abi.encode(100e18)
        );

        directGovernanceFarmerFacet.withdraw(1, address(token0));
    }

    function testWithdrawMultiple_ShouldWithdraw() public {
        address userAddress = address(0x100);
        address stakingAddress = address(0x101);
        address stakingShareAddress = address(0x102);

        // admin sets staking and staking share addresses
        vm.startPrank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingContractAddress(
            stakingAddress
        );
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );
        vm.stopPrank();

        // mint 100 Dollars to user
        vm.startPrank(admin);
        dollar.mint(userAddress, 100e18);
        vm.stopPrank();

        vm.startPrank(userAddress);
        // user allows DirectGovernanceFarmerHarness to spend user's Dollars
        dollar.approve(address(directGovernanceFarmerFacet), 100e18);
        assertEq(dollar.balanceOf(userAddress), 100e18);
        // mint 100 DAI to user
        token0.mint(userAddress, 100e18);
        // user allows DirectGovernanceFarmerHarness to spend user's DAI
        token0.approve(address(directGovernanceFarmerFacet), 99e18);
        assertEq(token0.balanceOf(userAddress), 100e18);
        // mint 100 USDC to user
        token1.mint(userAddress, 100e18);
        // user allows DirectGovernanceFarmerHarness to spend user's USDC
        token1.approve(address(directGovernanceFarmerFacet), 98e18);
        assertEq(token1.balanceOf(userAddress), 100e18);
        // mint 100 USDT to user
        token2.mint(userAddress, 100e18);
        // user allows DirectGovernanceFarmerHarness to spend user's USDT
        token2.approve(address(directGovernanceFarmerFacet), 97e18);
        assertEq(token2.balanceOf(userAddress), 100e18);

        // prepare mocks for deposit
        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(IDepositZap.add_liquidity.selector),
            abi.encode(100e18)
        );
        vm.mockCall(
            stakingAddress,
            abi.encodeWithSelector(IStaking.deposit.selector),
            abi.encode(1)
        );
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                address(directGovernanceFarmerFacet),
                userAddress,
                1,
                1,
                "0x"
            ),
            ""
        );

        // user deposits 100 Dollars, 99 DAI 98 USDC 97 USDT for 1 week
        directGovernanceFarmerFacet.depositMulti(
            [uint256(100e18), uint256(99e18), uint256(98e18), uint256(97e18)],
            1
        );

        // wait 1 week + 1 day
        vm.warp(block.timestamp + 8 days);

        // prepare mocks for withdraw
        uint256[] memory stakingShareIds = new uint256[](1);
        stakingShareIds[0] = 1;
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSelector(IERC1155Ubiquity.holderTokens.selector),
            abi.encode(stakingShareIds)
        );

        IStakingShare.Stake memory stake;
        stake.lpAmount = 100e18;
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSelector(IStakingShare.getStake.selector),
            abi.encode(stake)
        );

        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(IDepositZap.remove_liquidity.selector),
            abi.encode([100e18, 99e18, 98e18, 97e18])
        );
        vm.expectEmit(
            true,
            true,
            true,
            true,
            address(directGovernanceFarmerFacet)
        );
        emit WithdrawAll(
            userAddress,
            1,
            [uint256(100e18), uint256(99e18), uint256(98e18), uint256(97e18)]
        );
        uint256[4] memory tokenAmounts = directGovernanceFarmerFacet.withdrawId(
            1
        );
        vm.stopPrank();
        assertEq(tokenAmounts[0], 100e18);
        assertEq(tokenAmounts[1], 99e18);
        assertEq(tokenAmounts[2], 98e18);
        assertEq(tokenAmounts[3], 97e18);
        assertEq(dollar.balanceOf(userAddress), 100e18);
        assertEq(token0.balanceOf(userAddress), 100e18);
        assertEq(token1.balanceOf(userAddress), 100e18);
        assertEq(token2.balanceOf(userAddress), 100e18);
    }

    // END Multiple

    function testIsIdIncludedReturnTrueIfIdIsInTheList() public {
        address userAddress = address(0x100);
        address stakingAddress = address(0x101);
        address stakingShareAddress = address(0x102);

        // admin sets staking and staking share addresses
        vm.startPrank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingContractAddress(
            stakingAddress
        );
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );
        vm.stopPrank();

        vm.startPrank(userAddress);
        token0.mint(userAddress, 100e18);
        token0.approve(address(directGovernanceFarmerFacet), 100e18);

        // prepare mocks for deposit
        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(IDepositZap.add_liquidity.selector),
            abi.encode(100e18)
        );
        vm.mockCall(
            stakingAddress,
            abi.encodeWithSelector(IStaking.deposit.selector),
            abi.encode(1)
        );
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                address(directGovernanceFarmerFacet),
                userAddress,
                1,
                1,
                "0x"
            ),
            ""
        );

        directGovernanceFarmerFacet.depositSingle(address(token0), 1, 1);
        vm.stopPrank();
        // run assertions
        uint256[] memory list = new uint256[](1);
        list[0] = 1;
        assertTrue(directGovernanceFarmerFacet.isIdIncluded(list, 1));
    }

    function testIsIdIncludedReturnFalseIfIdIsNotInTheList() public {
        address userAddress = address(0x100);
        address stakingAddress = address(0x101);
        address stakingShareAddress = address(0x102);

        // admin sets staking and staking share addresses
        vm.startPrank(admin);
        IUbiquityDollarManager(dollarManagerAddress).setStakingContractAddress(
            stakingAddress
        );
        IUbiquityDollarManager(dollarManagerAddress).setStakingShareAddress(
            stakingShareAddress
        );
        vm.stopPrank();

        vm.startPrank(userAddress);
        token0.mint(userAddress, 100e18);
        token0.approve(address(directGovernanceFarmerFacet), 100e18);

        // prepare mocks for deposit
        vm.mockCall(
            depositZapAddress,
            abi.encodeWithSelector(IDepositZap.add_liquidity.selector),
            abi.encode(100e18)
        );
        vm.mockCall(
            stakingAddress,
            abi.encodeWithSelector(IStaking.deposit.selector),
            abi.encode(1)
        );
        vm.mockCall(
            stakingShareAddress,
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                address(directGovernanceFarmerFacet),
                userAddress,
                1,
                1,
                "0x"
            ),
            ""
        );

        directGovernanceFarmerFacet.depositSingle(address(token0), 1, 1);
        vm.stopPrank();

        // run assertions
        uint256[] memory list = new uint256[](1);
        assertFalse(directGovernanceFarmerFacet.isIdIncluded(list, 2));
    }
}
