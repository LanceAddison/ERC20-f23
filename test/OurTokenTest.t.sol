// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address public deployerAddress;

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfers() public {
        uint256 transferAmount = 200;

        // Transfer from user1 to user2
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    function testBurn() public {
        uint256 burnAmount = 500;

        vm.prank(bob);
        ourToken.burn(burnAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - burnAmount);
        assertEq(
            ourToken.totalSupply(),
            deployer.INITIAL_SUPPLY() - burnAmount
        );
    }

    function testFailTransferFromMoreThanAllowance() public {
        uint256 transferAmount = 1000;

        vm.prank(bob);
        ourToken.approve(alice, transferAmount / 2);

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
    }
}
