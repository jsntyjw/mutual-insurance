// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20_SGDT.sol";

// contract UnemploymentInsurance is Ownable {
contract UnemploymentInsurance {
    address private _owner;

    // ERC20 token
    address SGDTAddress = 0xa5Eeb3661ED2FA716E7DB8A9B8ec5d07274d4a71;
    SGDT SGDToken = SGDT(SGDTAddress);
    // address private SGDTAddress;
    // SGDT SGDToken;

    struct Employee {
        address walletAddress;
        string employeeName;
        string companyName;
        string emailAddress;
        string nric;
        uint256 monthlySalary;
        uint contributionAmount;
        uint payout;
        uint[] paymentTimestamps;
        uint monthsPaid;
        uint8 status; 
        uint verifiedTimestamp;
        uint registerTimestamp;
    }

    /**
        status:
        0 - 空用户，未注册（Unregistered）
        1 - 已注册，HR未验证（Pending HR Comfirmation）
        2 - HR已验证，3月等待期未过（Waiting Period）
        3 - 3月等待期已过，只要没欠费就能claim（Active）
        4 - 已经提交Claim（Claim Submitted）
        5 - 理赔完成（Claim Comfirmed）
        6 - 欠费过久，被踢出保险计划（Terminated）
        任何时候手动退出计划，状态回到 0 - Unregistered
     */

    struct Company {
        address hrWallet;
        bytes32 companyNameHash;
        string companyName;
        address[] employeeAddresses;
    }

    uint public verifyWaitingTime = 30 seconds;


    mapping(bytes32 => Company) public companiesByHash;
    mapping(address => Employee) public employees;
    mapping(address => bytes32) public hrWallets;     // hrWallet => companyNameHash

    event CompanyRegistered(bytes32 companyNameHash, string companyName);
    event EmployeeRegistered(address indexed employeeAddress, string companyName);
    event EmployeeStatusChanged(address indexed employeeAddress, uint8 status);
    event PremiumPaid(address indexed employeeAddress, uint amount, uint timestamp);
    event ClaimSubmitted(address indexed employeeAddress);
    event ClaimConfirmed(address indexed employeeAddress, uint payout);
    event EmployeeExited(address indexed employeeAddress);


    constructor() {
        _owner = msg.sender;
    }
    // constructor() Ownable(msg.sender) { }
    // constructor(address SGDAddr) {
    //     _owner = msg.sender;
    //     SGDTAddress = SGDAddr;
    //     SGDToken = SGDT(SGDTAddress);

    // }
    modifier onlyOwner(){
        require(_owner == msg.sender, "Only the owner of the contract can add company");
        _;
    }

    // Function to register a company
    function registerCompany(string memory companyName, address hrWallet) public onlyOwner {
        bytes32 companyNameHash = generateNameHash(companyName);
        require(companiesByHash[companyNameHash].hrWallet == address(0), "Company already registered");
        require(bytes(companyName).length > 0, "Company name cannot be empty");
        require(hrWallet != address(0), "HR wallet address cannot be zero");
        companiesByHash[companyNameHash] = Company(hrWallet, companyNameHash, companyName, new address[](0));
        hrWallets[hrWallet] = companyNameHash;
        emit CompanyRegistered(companyNameHash, companyName);
    }

    // Function to register an employee
    function registerEmployee(string memory companyName, uint salary, string memory employeeName, string memory emailAddress, string memory nric) public {
        require(bytes(companyName).length > 0, "Company name cannot be empty");
        require(salary > 0, "Salary must be greater than zero");
        bytes32 companyNameHash = generateNameHash(companyName);
        require(companiesByHash[companyNameHash].hrWallet != address(0), "Company does not exist");
        Company storage company = companiesByHash[companyNameHash];
        company.employeeAddresses.push(msg.sender);
        uint payout = calculatePayout(salary);
        uint contributionAmount = determineContribution(salary);
        employees[msg.sender] = Employee(msg.sender, employeeName, companyName, emailAddress, nric, salary, contributionAmount, payout, new uint[](0), 0, 1, 0, block.timestamp);
        emit EmployeeStatusChanged(msg.sender, employees[msg.sender].status);
        emit EmployeeRegistered(msg.sender, companyName);
    }

    // Function to confirm employment status by HR
    function confirmEmploymentStatus(address employeeAddress) public {
        bytes32 companyNameHash = hrWallets[msg.sender];
        require(msg.sender == companiesByHash[companyNameHash].hrWallet, "Only HR can confirm employment status.");
        Employee storage employee = employees[employeeAddress];
        require(employee.status == 1, "No need to confirm Employment Status.");
        employee.status = 2;    // Set status to "Waiting Period"
        employee.verifiedTimestamp = block.timestamp;
        emit EmployeeStatusChanged(employeeAddress, employee.status);
    }

    // Function to pay premium
    function payPremium(uint months) public payable {
        Employee storage employee = employees[msg.sender];
        if (employee.paymentTimestamps.length != 0) {
            checkPaymentOverdue(msg.sender);
        }
        require(employee.status != 0, "Not Registered!");
        require(employee.status != 1, "Registration not confirmed yet!");
        require(employee.status != 4, "Claim request already made, pending approval!");
        require(employee.status != 5, "Already claimed!");
        require(employee.status != 6, "Terminated due to unpaid premiums overdue!");
        require(employee.status == 2 || employee.status == 3, "Not in a valid state to pay premiums.");
        // require(msg.value == employee.contributionAmount * months, "Incorrect premium amount.");
        uint newAmountPaid = employee.contributionAmount * months;
        require(SGDToken.allowance(msg.sender, address(this)) >= newAmountPaid, "SGDT allowance is not enough.");
        require(SGDToken.balanceOf(msg.sender) >= newAmountPaid, "Balance not enough");
        require(SGDToken.transferFrom(msg.sender, address(this), newAmountPaid), "Deposit failed");
        for (uint i = 0; i < months; i++) {
            employee.paymentTimestamps.push(block.timestamp);
        }
        employee.monthsPaid += months;
        checkEnoughWaitingTime(msg.sender);
        emit PremiumPaid(msg.sender, newAmountPaid, block.timestamp);
    }



    // Function to submit a claim
    function submitClaim() public {
        checkPaymentOverdue(msg.sender);
        checkEnoughWaitingTime(msg.sender);
        Employee storage employee = employees[msg.sender];
        require(employee.status != 0, "Not Registered!");
        require(employee.status != 1, "Registration not confirmed yet!");
        require(employee.status != 2, "Still in Waiting Period!");
        require(employee.status != 4, "Claim request already made, pending approval!");
        require(employee.status != 5, "Already claimed!");
        require(employee.status != 6, "Terminated due to unpaid premiums overdue!");
        require(employee.status == 3, "Invalid Status!");
        require(block.timestamp < employee.paymentTimestamps[0] + employee.monthsPaid * 30 days, "Insurance expired, please renew first!");
        employee.status = 4;    // Set status to "Claim submitted"
        emit EmployeeStatusChanged(msg.sender, employee.status);
        emit ClaimSubmitted(msg.sender);
    }

    // Function to confirm claim
    function confirmClaim(address employeeAddress) public {
        bytes32 companyNameHash = hrWallets[msg.sender];
        require(companyNameHash != bytes32(0),"User is not a HR!");
        require(msg.sender == companiesByHash[companyNameHash].hrWallet, "Only HR can confirm the claim.");
        Employee storage employee = employees[employeeAddress];
        checkEnoughWaitingTime(msg.sender);
        require(employee.status != 0, "Not Registered!");
        require(employee.status != 1, "Registration not confirmed yet!");
        require(employee.status != 2, "Still in Waiting Period!");
        require(employee.status != 5, "Already claimed!");
        require(employee.status != 6, "Terminated due to unpaid premiums overdue!");
        require(employee.status == 4, "No submitted claim found!");

        require(SGDToken.balanceOf(address(this)) > employee.payout, "Insufficient funds in pool.");
        require(SGDToken.transfer(employeeAddress, employee.payout), "Unable to transfer.");
        employee.status = 5;    // Set status to "Claim Comfirmed"
        emit EmployeeStatusChanged(employeeAddress, employee.status);
        emit ClaimConfirmed(employeeAddress, employee.payout);
    }

    // Function to exit the insurance system
    function exit() public {
        Employee storage employee = employees[msg.sender];

        bytes32 companyNameHash = generateNameHash(employee.companyName);
        Company storage company = companiesByHash[companyNameHash];
        for (uint i = 0; i < company.employeeAddresses.length; i++) {
            if (company.employeeAddresses[i] == msg.sender) {
                company.employeeAddresses[i] = company.employeeAddresses[company.employeeAddresses.length - 1];
                company.employeeAddresses.pop();
            }
        }
        employee.companyName = "";
        employee.status = 0;    // Set status to "Unregistered"
        emit EmployeeStatusChanged(msg.sender, employee.status);
        emit EmployeeExited(msg.sender);
    }

    // Funtion to update verify waiting time
    function updateVerifyWaitingTime(uint num) public onlyOwner {
        verifyWaitingTime = num * 1 seconds;
    }


// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> View functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // View function to get employee information
    function getEmployeeInfo(address employeeAddress) public view returns (Employee memory) {
        return employees[employeeAddress];
    }

    // View function to get company information
    function getCompanyInfo(string memory companyName) public view returns (Company memory) {
        bytes32 companyNameHash = generateNameHash(companyName);
        return companiesByHash[companyNameHash];
    }

    // View funtion to get the address's identity (employee or hr)
    function getAddressIdentity() public view returns (string memory) {
        if (hrWallets[msg.sender] == 0x0) {
            return "employee";
        } else {
            bytes32 companyNameHash = hrWallets[msg.sender];
            string memory companyName = companiesByHash[companyNameHash].companyName;
            return companyName;
        }
    }

    // View funtion to get all employee information by company name
    function getAllEmployeeByCompanyName() public view returns (Employee[] memory) {
        bytes32 companyNameHash = hrWallets[msg.sender];
        require(companyNameHash != 0x0, "Only HR can view employee information of the company.");
        Company storage company = companiesByHash[companyNameHash];
        Employee[] memory employeeByCompanyName = new Employee[](company.employeeAddresses.length);
        for (uint i = 0; i < company.employeeAddresses.length; i++) {
            employeeByCompanyName[i] =  employees[company.employeeAddresses[i]];
        }
        return employeeByCompanyName;
    }

    // View funtion to get verify waiting time
    function getVerifyWaitingTime() public view returns (uint) {
        return verifyWaitingTime;
    }

    // View funtion to get SGDT Pool balance of contract
    function getPoolBalance() public view returns (uint) {
        return SGDToken.balanceOf(address(this));
    }


// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Helper function to check if the employ has exceeded the 3 month limit after last payment before each action
    function checkPaymentOverdue(address employeeAddress) public {
        Employee storage employee = employees[employeeAddress];
        require(employee.status != 0, "Not Registered!");
        require(employee.status != 5, "Already claimed!");
        if (block.timestamp > employee.paymentTimestamps[0] + employee.monthsPaid * 30 days + 3 *30 days) {
            employee.status = 6;    // Set status to "Terminated" due to not paid for too long
            emit EmployeeStatusChanged(employeeAddress, employee.status);
        }
    }
    
    // Helper function to check if the waiting time has passed
    function checkEnoughWaitingTime(address employeeAddress) public {
        Employee storage employee = employees[employeeAddress];
        require(employee.paymentTimestamps.length != 0,"Please Pay to activate your Insurance!");
        if (employee.status == 2 && block.timestamp > employee.verifiedTimestamp + verifyWaitingTime) {
            employee.status = 3;    // Set status to "Active"
            emit EmployeeStatusChanged(employeeAddress, employee.status);
        }
    }

    // Helper function to generate hash of company name
    function generateNameHash(string memory name) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(name));
    }

    // Helper function to determine contribution based on salary
    function determineContribution(uint salary) private pure returns (uint) {
        if (salary <= 2000) {
            return 20 ether;
        } else if (salary <= 5000) {
            return 40 ether;
        } else if (salary <= 10000) {
            return 60 ether;
        } else {
            return 80 ether;
        }
    }

    // Helper function to calculate payout
    function calculatePayout(uint salary) public pure returns (uint) {
        if (salary <= 2000) {
            return salary * 50 ether / 100;
        } else if (salary <= 5000) {
            return salary * 40 ether / 100;
        } else if (salary <= 10000) {
            return salary * 30 ether / 100;
        } else {
            return salary * 20 ether / 100;
        }
    }

}