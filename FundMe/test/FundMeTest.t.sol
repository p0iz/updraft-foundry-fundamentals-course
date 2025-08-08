// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address private user = makeAddr("TestUser");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe dfm = new DeployFundMe();
        fundMe = dfm.run();
        vm.deal(user, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersionIsCorrect() public view {
        uint256 number = fundMe.getVersion();
        assertEq(number, 4);
    }

    function testFundFailsWithTooLittleEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(user);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFunded() public funded {
        assertEq(fundMe.getAmountFunded(user), SEND_VALUE);
    }
    

    function testFunderAddedAfterFunding() public funded {
        assertEq(fundMe.getFunder(0), user);
    }

    function testOnlyOwnerCanWithdraw() public funded  {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOwnerCanWithdraw() public funded {
        uint256 ownerStartBalance = fundMe.getOwner().balance;
        uint256 fundMeStartBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerEndBalance = fundMe.getOwner().balance;
        uint256 fundMeEndBalance = address(fundMe).balance;

        assertEq(ownerEndBalance, fundMeStartBalance + ownerStartBalance);
        assertEq(fundMeEndBalance, 0);
    }

    function testMultipleFunders() public {
        uint160 numFunders = 10;
        uint160 nextFunderIndex = 1;
        for (uint160 i = nextFunderIndex; i < numFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartBalance = fundMe.getOwner().balance;
        uint256 fundMeBalanceAfterFunding = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerEndBalance = fundMe.getOwner().balance;
        uint256 fundMeEndBalance = address(fundMe).balance;
        
        assertEq(ownerEndBalance, ownerStartBalance + fundMeBalanceAfterFunding);
        assertEq(fundMeEndBalance, 0);
    }
}