// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/UnemploymentInsurance.sol";

contract UnemploymentInsuranceTest is Test {
    UnemploymentInsurance insuranceContract;
    address owner;
    address hrWallet;
    address employeeWallet1;
    address employeeWallet2;
    address employeeWallet3;
    string companyName;
    uint initBalance;
    uint256 startTime;

    function setUp() public {
        owner = makeAddr("owner");
        hrWallet = makeAddr("hr1");
        employeeWallet1 = makeAddr("user1");
        employeeWallet2 = makeAddr("user2");
        employeeWallet3 = makeAddr("user3");

        // deploy contract
        vm.prank(owner);
        insuranceContract = new UnemploymentInsurance();

        // Register company
        companyName = "TestCompany";
        vm.prank(owner);
        insuranceContract.registerCompany(companyName, hrWallet);

        // employee 1
        uint salary1 = 3000; // Corresponds with a $40 contribution per month
        string memory employeeName1 = "employee1";
        string memory emailAddress1 = "employee1@example.com";
        string memory nric1 = "S1234567D";

        // Register employees
        vm.prank(employeeWallet1);
        insuranceContract.registerEmployee(companyName, salary1, employeeName1, emailAddress1, nric1);

        // employee 2
        uint salary2 = 7000; // Corresponds with a $60 contribution per month
        string memory employeeName2 = "employee2";
        string memory emailAddress2 = "employee2@example.com";
        string memory nric2 = "S1234567F";

        // Register employees
        vm.prank(employeeWallet2);
        insuranceContract.registerEmployee(companyName, salary2, employeeName2, emailAddress2, nric2);

        // Initial balance for payment testing
        initBalance = 1000 ether;
        vm.deal(employeeWallet1, initBalance);
        vm.deal(employeeWallet2, initBalance);

        // starting time 
        startTime = block.timestamp;

    }



    function testNormalClaimProcess() public {

        // Confirm employment status by HR
        vm.prank(hrWallet);
        insuranceContract.confirmEmploymentStatus(companyName, employeeWallet1);

        // Employee 1 pays premium for 4 months
        uint premium1 = insuranceContract.getEmployeeInfo(employeeWallet1).contributionAmount;
        uint months = 4;
        vm.prank(employeeWallet1);
        insuranceContract.payPremium{value: premium1 * months}(months);

        // Employee 1 submits a claim in less than 3 months
        vm.prank(employeeWallet1);
        vm.expectRevert("Not enough monthly payments made or not enough time after enrolled!");
        insuranceContract.submitClaim();

        // set time
        vm.warp(startTime + 3*30 days +1 days);  

        // Employee 1 submits a claim after 3 months
        vm.prank(employeeWallet1);
        insuranceContract.submitClaim();

        // HR confirms the claim for employee 1
        vm.prank(hrWallet);
        insuranceContract.confirmClaim("TestCompany", employeeWallet1);

        // Check if the payout was correct
        uint expectedPayout = insuranceContract.calculatePayout(3000); // should correspond with 40% of $3000, capped at $2,000
        assertEq(address(employeeWallet1).balance, initBalance - (premium1 * months) + expectedPayout, "Wrong final balance for employee");
        
        vm.prank(employeeWallet1);
        vm.expectRevert("Already claimed or exited!");
        insuranceContract.submitClaim();
    }



    function testNotEnoughPayments() public {

        // Confirm employment status by HR
        vm.prank(hrWallet);
        insuranceContract.confirmEmploymentStatus(companyName, employeeWallet2);

        // Employee 2 pays premium but only for 2 months, should not be able to claim   <<<<<<<<<<<<<<<<<
        uint premium2 = insuranceContract.getEmployeeInfo(employeeWallet2).contributionAmount;
        vm.prank(employeeWallet2);
        insuranceContract.payPremium{value: premium2 * 2}(2);

        // Employee 2 should not be able to submit claim due to insufficient payments
        vm.prank(address(employeeWallet2));
        vm.expectRevert("Not enough monthly payments made or not enough time after enrolled!");
        insuranceContract.submitClaim();
    }



    function testTooLongIntervalAfterPayment() public {
        // set time
        vm.warp(startTime + 100 days );  

        // Confirm employment status by HR
        vm.prank(hrWallet);
        insuranceContract.confirmEmploymentStatus(companyName, employeeWallet1);

        // Employee 1 pays premium for 4 months
        uint premium1 = insuranceContract.getEmployeeInfo(employeeWallet1).contributionAmount;
        uint months = 4;
        vm.prank(employeeWallet1);
        insuranceContract.payPremium{value: premium1 * months}(months);

        // After a long long time   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        vm.warp(startTime + 100 days + 8*30 days );  

        // Employee 1 submits a claim
        vm.prank(employeeWallet1);
        vm.expectRevert("Already claimed or exited!");
        insuranceContract.submitClaim();



        // Confirm employment status by HR
        vm.prank(hrWallet);
        insuranceContract.confirmEmploymentStatus(companyName, employeeWallet2);

        // Employee 2 pays premium but only for 2 months
        uint premium2 = insuranceContract.getEmployeeInfo(employeeWallet2).contributionAmount;
        vm.prank(employeeWallet2);
        insuranceContract.payPremium{value: premium2 * 2}(2);

        // Employee 2 pays premium after 4 months, too long interval    <<<<<<<<<<<<<<<<<<<<<<
        vm.warp(startTime + 5000 days );   
        premium2 = insuranceContract.getEmployeeInfo(employeeWallet2).contributionAmount;
        vm.prank(employeeWallet2);
        vm.expectRevert("Already claimed or exited!");
        insuranceContract.payPremium{value: premium2 * 10}(10);


    }


}