// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PKRN is ERC20, ERC20Burnable, AccessControl, Ownable, ERC20Pausable {

    bytes32 public constant MINTER_ROLE= keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE= keccak256("PAUSER_ROLE");

    mapping(address user => bool isBlacklist) public blacklisted;

    // ---------------- CUSTOM ERROR-----------------
    error ADDRESS_BLACKLIST();

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);

    constructor(address admin, address initialMinter) ERC20("Pakistan Stable coin","PKRN") Ownable(msg.sender){
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, initialMinter);
        _grantRole(PAUSER_ROLE, admin);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE){
        _mint(to, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE){
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE){
        _unpause();
    }

    function blacklist(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        blacklisted[account]= true;
        emit Blacklisted(account);
    }

    function unblacklist(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        blacklisted[account]= false;
        emit UnBlacklisted(account);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) whenNotPaused {
        if(blacklisted[from] || blacklisted[to]){
            revert ADDRESS_BLACKLIST();
        }

        super._update(from, to, value);
    }

    function decimals() public view virtual override returns(uint8){
        return 6;
    }
}
