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
        token = new Token(address(this));
    }

    function test_SetUpState() public {
        assertEq(
            token.balanceOf(token.DEVELOPMENT_FUND_ADDRESS()),
            15_000_000 ether,
            "Incorrect development fund balance"
        );
        assertEq(
            token.balanceOf(token.TEAM_RESERVE_ADDRESS()),
            6_000_000 ether,
            "Incorrect team reserve balance"
        );
        assertEq(
            token.balanceOf(token.PARTNERS_ADVISORS_ADDRESS()),
            3_000_000 ether,
            "Incorrect partners-advisors balance"
        );
        assertEq(
            token.balanceOf(token.PRESALES_ADDRESS()),
            4_000_000 ether,
            "Incorrect presales fund balance"
        );
        assertEq(
            token.balanceOf(token.PUBLICSALE_ADDRESS()),
            24_000_000 ether,
            "Incorrect public sale fund balance"
        );
        assertEq(
            token.balanceOf(token.LIQUIDTY_ADDRESS()),
            2_000_000 ether,
            "Incorrect liquidity sale fund balance"
        );
    }

    function test_InitialBalance() public {
        uint expected = 15_000_000 ether;
        uint balance = token.balanceOf(address(0x123));
        assertEq(
            balance,
            expected,
            "Initial balance should be 15_000_000 * 10**18 tokens"
        );
    }

    function test_Mint() public {
        uint initialSupply = token.totalSupply();
        token.mint(tester, 100 ether);
        uint finalSupply = token.totalSupply();
        assertEq(
            finalSupply - initialSupply,
            100 ether,
            "Token supply increase should be 100 * 10**18"
        );
    }

    /**
    * Should not be able to mint more than max
    */
    function testFail_MintLimits() public {
        token.mint(tester, 101_000_000 ether);
    }

    function testFail_UnauthorizedMint() public {
        vm.prank(tester);
        token.mint(tester, 100 ether);
    }

    function test_Allowance() public {
        vm.prank(tester);
        token.increaseAllowance(address(0x71), 100 ether);
        assertEq(
            token.allowance(tester, address(0x71)),
            100 ether,
            "Incorrect allowance"
        );

        vm.prank(tester);
        token.decreaseAllowance(address(0x71), 10 ether);
        assertEq(
            token.allowance(tester, address(0x71)),
            90 ether,
            "Incorrect allowance"
        );
    }

    function test_Transfer() public {
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

    function test_TransferFrom() public {
        token.mint(tester, 100 ether);
        vm.prank(tester);
        address to = address(0x71);

        token.increaseAllowance(to, 100 ether);

        uint amount = 10 ether;

        // Transfer tokens
        vm.prank(to);
        token.transferFrom(tester, to, amount);

        // Check balances
        uint fromBalance = token.balanceOf(tester);
        uint toBalance = token.balanceOf(to);
        assertEq(fromBalance, 90 ether, "From balance should be 90 tokens");
        assertEq(toBalance, 10 ether, "To balance should be 10 tokens");
    }

    function test_Burn() public {
        address burner = address(0xdead);
        token.mint(burner, 10 ether);
        uint initialSupply = token.totalSupply();
        vm.prank(burner);
        token.burn(1 ether);
        uint finalSupply = token.totalSupply();
        uint balance = token.balanceOf(burner);
        assertEq(balance, 9 ether, "burner balance should be 9 tokens");
        assertEq(
            initialSupply - finalSupply,
            1 ether,
            "token supply must decrease"
        );
    }

    function test_BurnFrom() public {
        address burner = address(0xdead);
        token.mint(tester, 10 ether);
        vm.prank(tester);
        token.increaseAllowance(burner, 10 ether);

        vm.prank(burner);
        token.burnFrom(tester, 1 ether);
        uint balance = token.balanceOf(tester);
        assertEq(balance, 9 ether, "burner balance should be 9 tokens");
    }
}
