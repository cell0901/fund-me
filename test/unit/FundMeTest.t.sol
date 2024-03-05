// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundeMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 1 ether;

    function setUp() external {
        vm.deal(USER, INITIAL_BALANCE);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    //**TESTS */
    // 1. UNIT
    //  - Testing a specific part of code
    // 2 INTERGRATION
    // - Testing the code with other parts of code
    // 3 FORKED
    // - Testing the code in real simulated environment
    // 4 STAGING
    // - Testing the code in real env that is real mainnet(or testnet).

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        // us -> fundMeTest -> FundMe
        assertEq(fundMe.getOwner(), msg.sender); // fundme test is owner as it is deploying the fundMe contract
    }

    function testFailMininumdollarIsNotFive() public {
        assertEq(fundMe.MINIMUM_USD(), 2e18);
    }

    function testPriceFeedVersion() public {
        // using a forked/RPC sepolia rpc url, anvil spin up and simulate txn as if they were running in sepolia chain
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // hey the next line should revert/fails
        fundMe.fund(); // this line will fail because we are not passing any value to send
    }

    function testFundUpdatesDataStructure() public funded {
        uint256 amountFunded = fundMe.getAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrwWithSingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunder() public funded {
        uint160 numberOfFunder = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunderCheaper() public funded {
        uint160 numberOfFunder = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
