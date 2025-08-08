// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;

    function setUp() public {
        simpleStorage = new SimpleStorage();
    }

    function testSetValue() public {
        assertEq(simpleStorage.getValue(), 42);
        simpleStorage.setValue(1);
        assertEq(simpleStorage.getValue(), 1);
    }
}
