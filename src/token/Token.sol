// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import "openzeppelin/access/AccessControl.sol";

interface IAntisnipe {
    function assureCanTransfer(
        address sender,
        address from,
        address to,
        uint256 amount
    ) external;
}

/// @title 3Verse Token contract
contract Token is ERC20, ERC20Burnable, ERC20Permit, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // "ether" is used here to get 18 decimals
    uint immutable MAX_SUPPLY = 100_000_000 ether;
    uint256 public constant DEVELOPMENT_FUND = 15_000_000 ether;
    uint256 public constant TEAM_RESERVE = 6_000_000 ether;
    uint256 public constant PARTNERS_ADVISORS = 3_000_000 ether;
    uint256 public constant PRESALES = 4_000_000 ether;
    uint256 public constant PUBLICSALE = 24_000_000 ether;
    uint256 public constant LIQUIDTY = 2_000_000 ether;

    // SAFE multisig addresses 
    address public constant DEVELOPMENT_FUND_ADDRESS = address(0x123);
    address public constant TEAM_RESERVE_ADDRESS = address(0x124);
    address public constant PARTNERS_ADVISORS_ADDRESS = address(0x125);
    address public constant PRESALES_ADDRESS = address(0x126);
    address public constant PUBLICSALE_ADDRESS = address(0x127);
    address public constant LIQUIDTY_ADDRESS = address(0x128);
    
    IAntisnipe public antisnipe;
    bool public antisnipeDisable;
    
    constructor(address owner) ERC20("3VERSE", "VERS") ERC20Permit("3VERSE") {
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(MINTER_ROLE, owner);

        _mint(DEVELOPMENT_FUND_ADDRESS, DEVELOPMENT_FUND);
        _mint(TEAM_RESERVE_ADDRESS, TEAM_RESERVE);
        _mint(PARTNERS_ADVISORS_ADDRESS, PARTNERS_ADVISORS);
        _mint(PRESALES_ADDRESS, PRESALES);
        _mint(PUBLICSALE_ADDRESS, PUBLICSALE);
        _mint(LIQUIDTY_ADDRESS, LIQUIDTY);
    }

    /**
    * @dev allow minting of tokens upto the MAX SUPPLY by MINTER
    */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply reached");
        _mint(to, amount);
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(0) || to == address(0)) return;
        if (!antisnipeDisable && address(antisnipe) != address(0))
            antisnipe.assureCanTransfer(msg.sender, from, to, amount);
    }

    function setAntisnipeDisable() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!antisnipeDisable);
        antisnipeDisable = true;
    }

    function setAntisnipeAddress(address addr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        antisnipe = IAntisnipe(addr);
    }
}
