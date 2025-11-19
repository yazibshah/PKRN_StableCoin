/* // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PKRN} from "../src/PKRN.sol";

contract PKRNTest is Test {
    PKRN public pkrn;
    
    address public admin = makeAddr("admin");
    address public userA = makeAddr("userA");
    address public userB = makeAddr("userB");
    address public bridge = makeAddr("bridge");

    function setUp() public {
        pkrn = new PKRN(admin, bridge);     
    }

    function test_InitialValues() public view {
        assertEq(pkrn.name(), "Pakistan Stable coin");
        assertEq(pkrn.symbol(), "PKRN");
        assertEq(pkrn.decimals(), 6);
        assertEq(pkrn.totalSupply(), 0);
        assertTrue(pkrn.hasRole(pkrn.MINTER_ROLE(), bridge));
        assertTrue(pkrn.hasRole(pkrn.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_mintByMinter() public{
        uint256 amount= 1000e6;

        vm.startPrank(bridge);
        pkrn.mint(userA, amount);
        vm.stopPrank();

        assertEq(pkrn.balanceOf(userA), amount);
        assertEq(pkrn.totalSupply(), amount);
    }

} */