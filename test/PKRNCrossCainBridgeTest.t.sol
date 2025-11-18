// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PKRN} from "../src/PKRN.sol";
import {PKRNCrossChainBridge} from "../src/PKRNCrossChainBridge.sol";



contract PKRNCrossChainBridgeTest is Test{

    PKRN public pkrn;
    PKRNCrossChainBridge public bridge;

    address public admin = makeAddr("admin");
    address public operator = makeAddr("operator");
    address public user1= makeAddr("user1");
    address public user2= makeAddr("user2");
    address public attacker= makeAddr("attacker");

    uint256 public constant INITIAL_Supply= 10000e6;

    function setUp() public {
        
    }
    
    function test_checkBalance() public{
        vm.prank(admin);
        console.log(msg.sender.balance);
    }
}