// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), address(this));
    }

    function testGetVersionIsCorrect() public view {
        uint256 number = fundMe.getVersion();
        assertEq(number, 4);
    }
}