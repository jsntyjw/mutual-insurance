// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/UnemploymentInsurance.sol";

contract DeployUnemploymentInsurance is Script {
    function run() external {
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        // console.log(vm.envUint("PRIVATE_KEY"));
        console.log("The Deployer address:", deployer);
        console.log("Balance is:", deployer.balance);

        vm.startBroadcast(deployer);

        UnemploymentInsurance insurance = new UnemploymentInsurance();
        insurance.registerCompany("dbs",0x98c54F302b725b306bd1D554b7d23661294f5664);
        insurance.registerCompany("DBS",0x98c54F302b725b306bd1D554b7d23661294f5664);
        insurance.registerCompany("Tencent",0xB2ccaeaE836b2Dd1Dc8F3dc7c06Fe8Ea95f4aa97);

        vm.stopBroadcast();
        console.log("Contract deployed at:", address(insurance));

    }
}
