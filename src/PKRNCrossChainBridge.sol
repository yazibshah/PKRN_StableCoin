// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {PKRN} from "./PKRN.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract PKRNCrossChainBridge is AccessControl, ReentrancyGuard{
    // 
    PKRN public immutable pkRN;
    using SafeERC20 for PKRN;

    bytes32 public constant BRIDGE_OPERATOR = keccak256("BRIDGE_OPERATOR");

    mapping(bytes32 requests => bool isProceed) public processedRequests;

    // ----------------custom Errors------------
    error REQUEST_ALREADY_PROCEED();

    // ----------------Events------------
    event TokensLocked(address indexed user, uint256 amount, bytes32 indexed requestId, string destinationChain, string destinationChainAccountAddress);
    event TokenReleased(address indexed user, uint256 amount, bytes32 indexed requestId);

    constructor(address _pkRN, address admin){
        pkRN= PKRN(_pkRN);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(BRIDGE_OPERATOR, admin);
    }

function lockAndRemoteMint(
        uint256 amount,
        bytes32 requestId,
        string calldata destinationChain,
        string calldata destinationChainAccountAddress
    ) external nonReentrant {
        if (processedRequests[requestId]) {
            revert REQUEST_ALREADY_PROCEED();
        }

        processedRequests[requestId] = true;

        // This now checks return value AND works with non-reverting tokens
        pkRN.safeTransferFrom(msg.sender, address(this), amount);
        pkRN.burn(amount);

        emit TokensLocked(msg.sender, amount, requestId, destinationChain, destinationChainAccountAddress);
    }

    function release(address to, uint256 amount, bytes32 requestId) external onlyRole(BRIDGE_OPERATOR) nonReentrant{
        if(processedRequests[requestId]){
            revert REQUEST_ALREADY_PROCEED();
        }

        processedRequests[requestId] = true;

        pkRN.mint(to, amount);
        emit TokenReleased(to, amount, requestId);
    }

    function addOperator(address operator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BRIDGE_OPERATOR, operator);
    }

    function removeOperator(address operator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(BRIDGE_OPERATOR, operator);
    }
}