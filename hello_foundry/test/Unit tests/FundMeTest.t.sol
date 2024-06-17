// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

uint256 public number = 1;
FundMe fundMe;
address USER = makeAddr("user");
uint256 constant SEND_VALUE = 0.1 ether;
uint256 constant STARTING_VALUE = 10 ether;

function setUp() external {
     DeployFundMe deployFundMe = new DeployFundMe();
     fundMe = deployFundMe.run();
     vm.deal(USER, STARTING_VALUE);
}


modifier funded{
    vm.prank(USER);
    fundMe.fund{value: STARTING_VALUE}();
    _;
}

function testDemo() public view{
    assertEq(fundMe.MINIMUM_USD(), 5E18);
}

function testOwnerCheck () public view{
    assertEq(fundMe.i_owner(), msg.sender);
}

function testPricFeedVersionAccuracy() public view{
    uint256 version = fundMe.getVersion();
    assertEq(version, 4);
}

function testFundFailsWithoutEnoughEth() public {
    vm.expectRevert();
    fundMe.fund();
}

function testFundUpdatesFundedDataStructure() public {
    vm.prank(USER);
    
    fundMe.fund{value: SEND_VALUE}();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
}

function testAddsFunderToArrayFunder() public funded{
    

    address _funder = fundMe.getfunder(0);

    assertEq(USER, _funder);
}

function testOnlyOwnerWithdraw() public {
    
    vm.prank(USER);
    vm.expectRevert();
    fundMe.withdraw();
}

function testOwnerWithdrawal() public funded{
    //Arrange
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingContractBalance = address(fundMe).balance;
    
    //Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();
    
    //Assert
    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingContractBalance = address(fundMe).balance;
    
    assertEq(endingContractBalance, 0);
    assertEq(startingContractBalance + startingOwnerBalance, endingOwnerBalance);
}

function testFundWithMultipleFunders() public funded{
    uint160 totalFunders = 10;
    uint160 startingIndex = 1;

    for (uint160 i = startingIndex; i < totalFunders; i++) {
        
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }


    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingContractBalance = address(fundMe).balance;
    
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();
    
    assert(address(fundMe).balance == 0);
    assert(startingOwnerBalance + startingContractBalance == fundMe.getOwner().balance);

}

// function testFundWithMultipleFundersCheaper() public funded{
//    uint160 totalFunders = 10;
//     uint160 startingIndex = 1;

//     for (uint160 i = startingIndex; i < totalFunders; i++) {
        
//         hoax(address(i), SEND_VALUE);
//         fundMe.fund{value: SEND_VALUE}();
//     }


//     uint256 startingOwnerBalance = fundMe.getOwner().balance;
//     uint256 startingContractBalance = address(fundMe).balance;
    
//     vm.prank(fundMe.getOwner());
//     fundMe.cheaperWithdraw();
    
//     assert(address(fundMe).balance == 0);
//     assert(startingOwnerBalance + startingContractBalance == fundMe.getOwner().balance);

// }
}