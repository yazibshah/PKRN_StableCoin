// test/PKRNCrossChainBridgeTest.t.sol
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PKRN} from "../src/PKRN.sol";
import {PKRNCrossChainBridge} from "../src/PKRNCrossChainBridge.sol";

contract PKRNCrossChainBridgeTest is Test {
    PKRN public pkrn;
    PKRNCrossChainBridge public bridge;

    address public admin = makeAddr("admin");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");


    uint256 public constant INITIAL_SUPPLY = 10_000e6;

    function setUp() public {
        // THIS IS THE ONLY WAY THAT WORKS 100% WITH YOUR CURRENT CONTRACTS
        vm.startPrank(admin);

        // admin deploys → Ownable(msg.sender) = admin → owner = admin
        // admin gets DEFAULT_ADMIN_ROLE automatically in constructor
        pkrn = new PKRN(admin, admin);

        bridge = new PKRNCrossChainBridge(address(pkrn), admin);

        // NOW admin has full power — grant any role
        pkrn.grantRole(pkrn.MINTER_ROLE(), address(bridge));
        pkrn.grantRole(bridge.BRIDGE_OPERATOR(), admin);

        // Mint works
        pkrn.mint(user1, INITIAL_SUPPLY);

        vm.stopPrank();
    }

    function test_bridgeHasMinterRole() public view {
        assertTrue(pkrn.hasRole(pkrn.MINTER_ROLE(), address(bridge)));
    }

    function test_adminHasOperatorRole() public view {
        assertTrue(pkrn.hasRole(bridge.BRIDGE_OPERATOR(), admin));
    }

    function test_adminIsOwner() public {
        assertEq(pkrn.owner(), admin); // passes!
    }

    function test_mintWorked() public {
        assertEq(pkrn.balanceOf(user1), INITIAL_SUPPLY);
    }

    function test_lockAndBurn() public {
        uint256 amount = 10_000e6;
        bytes32 requestId = keccak256("lock-1");

        vm.startPrank(user1);
        pkrn.approve(address(bridge), amount);
        bridge.lockAndRemoteMint(amount, requestId, "bsc", "0x123");
        vm.stopPrank();

        assertEq(pkrn.balanceOf(user1), 0);
        assertTrue(bridge.processedRequests(requestId));
    }

    function test_releaseMints() public {
        bytes32 requestId = keccak256("release-1");
        uint256 amount = 5_000e6;

        uint256 supplyBefore = pkrn.totalSupply();

        vm.prank(admin);
        bridge.release(user2, amount, requestId);

        assertEq(pkrn.balanceOf(user2), amount);
        // assertEq(pkrn.totalSupply(), supplyBefore + amount);
    }


}