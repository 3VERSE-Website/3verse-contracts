// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


import "forge-std/console2.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "src/token/Token.sol";

contract TestToken is Test {
    Token token;
    address constant tester = address(42);
    address constant contractx = address(33);

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
        uint balance = token.balanceOf(address(0xCbe17f635E37E78D8a2d8baBD1569f1DeD3D4f87));
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

    function test_TaxTransfer() public {
        token.mint(tester, 100 ether);
        address from = tester;
        address to = address(0x69);
        uint amount = 100 ether;
        token.setTaxable(true, 25);

        // Transfer tokens
        vm.prank(tester);
        token.transfer(to, amount);

        // Check balances
        uint fromBalance = token.balanceOf(from);
        uint toBalance = token.balanceOf(to);
        uint feeBalance = token.balanceOf(address(0xdEFaE8a08FD0E3023eF7E14c08C622Ad4F22aC9A));
        assertEq(fromBalance, 0 ether, "From balance should be 90 tokens");
        assertEq(toBalance, 75 ether, "To balance should be 70 tokens");
        assertEq(feeBalance, 25 ether, "Fee balance should be 30 tokens");
    }

    function test_TaxExemptTransfer() public {
        token.mint(tester, 100 ether);
        address from = tester;
        address to = address(0x69);
        uint amount = 10 ether;
        token.setTaxable(true, 20);
        token.setTransferFeeExempt(tester);
        // Transfer tokens
        vm.prank(tester);
        token.transfer(to, amount);

        // Check balances
        uint fromBalance = token.balanceOf(from);
        uint toBalance = token.balanceOf(to);
        assertEq(fromBalance, 90 ether, "From balance should be 90 tokens");
        assertEq(toBalance, 10 ether, "To balance should be 10 tokens");
    }

    function test_TaxSet() public {
        token.setTaxable(true, 25);

        // Check tax
        uint percentage = token.percentage();
        bool taxable = token.taxable();
        assertEq(taxable, true, "Tax is set");
        assertEq(percentage, 25, "percentage is 25%");
    }

    function testFail_TaxSet() public {
        token.setTaxable(true, 26);
    }

    function test_TaxExemptTransferDifferentExemptor() public {
        bytes32 FEE_EXEMPTER_ROLE = keccak256("FEE_EXEMPTER_ROLE");

        token.mint(tester, 100 ether);
        address from = tester;
        address to = address(0x69);
        uint amount = 10 ether;
        token.setTaxable(true, 20);
        token.grantRole(FEE_EXEMPTER_ROLE, contractx);
        vm.prank(contractx);
        token.setTransferFeeExempt(tester);
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
