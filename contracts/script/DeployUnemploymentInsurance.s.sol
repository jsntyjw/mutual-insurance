// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

        vm.stopBroadcast();
        console.log("Contract deployed at:", address(insurance));

    }
}
