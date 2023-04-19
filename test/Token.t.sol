// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "src/token/Token.sol";

contract TestToken is Test {
    Token token;
    address constant tester = address(42);

    function setUp() public {
        token = new Token(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
    }

    function testInitialBalance() public {
        uint expected = 15_000_000 ether;
        uint balance = token.balanceOf(address(0x123));
        assertEq(
            balance,
            expected,
            "Initial balance should be 15_000_000 * 10**18 tokens"
        );
    }

    function testTransfer() public {
        token.mint(tester, 100 ether);
        address from = tester;
        address to = address(0x69);
        uint amount = 10 ether;

        // Transfer tokens
        vm.prank(tester);
        token.transfer(to, amount);

        // Check balances
        uint fromBalance = token.balanceOf(from);
        uint toBalance = token.balanceOf(to);
        assertEq(fromBalance, 90 ether, "From balance should be 90 tokens");
        assertEq(toBalance, 10 ether, "To balance should be 10 tokens");
    }
    /**
    * Should not be able to mint more than max
    */
    function testFailMintLimits() public {
        token.mint(tester, 101_000_000 ether);
    }

    function testBurn() public {
        address burner = address(0xdead);
        token.mint(burner, 10 ether);
        vm.prank(burner);
        token.burn(1 ether);
        uint balance = token.balanceOf(burner);
        assertEq(balance, 9 ether, "burner balance should be 9 tokens");
    }
 
}
