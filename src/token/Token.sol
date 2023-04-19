// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin/access/AccessControl.sol";
import "openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
/// @title 3Verse Token contract
contract Token is ERC20, ERC20Burnable, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // "ether" is used here to get 18 decimals
    uint immutable MAX_SUPPLY = 100_000_000 ether;
    uint256 public constant DEVELOPMENT_FUND = 15_000_000 ether;
    uint256 public constant TEAM_RESERVE = 8_000_000 ether;
    uint256 public constant PARTNERS_ADVISORS = 3_000_000 ether;
    uint256 public constant MARKETING = 8_000_000 ether;

    // to replace with safe addresses prior to deployment
    address public constant DEVELOPMENT_FUND_ADDRESS = address(0x123);
    address public constant TEAM_RESERVE_ADDRESS = address(0x124);
    address public constant PARTNERS_ADVISORS_ADDRESS = address(0x125);
    address public constant MARKETING_ADDRESS = address(0x126);
    
    constructor(address owner) ERC20("3VERSE", "3VE") ERC20Permit("3VERSE") {
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(MINTER_ROLE, owner);

        _mint(DEVELOPMENT_FUND_ADDRESS, DEVELOPMENT_FUND);
        _mint(TEAM_RESERVE_ADDRESS, TEAM_RESERVE);
        _mint(PARTNERS_ADVISORS_ADDRESS, PARTNERS_ADVISORS);
        _mint(MARKETING_ADDRESS, MARKETING);
    }

    /**
    * @dev allow minting of tokens upto the MAX SUPPLY by MINTER
    */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply reached");
        _mint(to, amount);
    }
}