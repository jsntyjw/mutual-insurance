<template>
  <div class="m-8">
    <div class="flex justify-between">
      <div class="flex mb-4">
        <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
        <div class="font-bold text-xl">Employment Verification</div>
      </div>
      <div class="btn btn-sm btn-ghost px-1.5">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
          class="w-5 h-5">
          <path stroke-linecap="round" stroke-linejoin="round"
            d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99" />
        </svg>
      </div>
    </div>
    <el-table :data="maskedEmployeeData" style="width: 100%">
      <el-table-column prop="maskedWalletAddress" label="walletAddress" width="180" />
      <el-table-column prop="emailAddress" label="email" width="180" />
      <el-table-column prop="nric" label="nric" />
      <el-table-column prop="monthlySalary" label="monthlySalary" />
      <el-table-column prop="status" label="status">
        <template #default="scope">
          <span>{{ getEmployeeStatus(scope.row.status) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="Action">
        <template #default="scope">
          <el-button v-if="getEmployeeStatus(scope.row.status) === 'Pending Confirmation'"
            @click="confirmEmploymentStatus(scope.row.walletAddress)">Verify</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>
<script setup>
import { ref, onMounted, computed } from 'vue';
import { ElTable, ElTableColumn, ElButton } from 'element-plus';
import { web3Provider } from '../utils/web3Provider.js';
import { contractAddress } from '../contract/contractConstants.js';
import contractABI from '../contract/contractABI.json';

const contract = new web3Provider.web3.eth.Contract(contractABI, contractAddress);
const employeeData = ref([]);

const maskedEmployeeData = computed(() => {
  return employeeData.value.map(employee => ({
    ...employee,
    maskedWalletAddress: maskWalletAddress(employee.walletAddress)
  }));
});

function maskWalletAddress(address) {
  if (address && address.length >= 10) {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  }
  return address;
}

async function getEmployeeInformation() {
  try {
    const accounts = await web3Provider.web3.eth.requestAccounts();
    const connectedWalletAddress = accounts[0];
    console.log("connected wallet address:" + connectedWalletAddress);
    const employeeInformation = await contract.methods.getAllEmployeeByCompanyName().call({ from: connectedWalletAddress });
    if (employeeInformation) {
      console.log("employeeInformation:" + employeeInformation);
      employeeData.value = employeeInformation;
    } else {
      console.log('No employee information fetched');
    }
  } catch (error) {
    console.error('Error getEmployeeInformation:', error);
  }
}

async function confirmEmploymentStatus(employeeAddress) {
  try {
    const accounts = await web3Provider.web3.eth.requestAccounts();
    const connectedWalletAddress = accounts[0];
    console.log("Confirming employment status for employee address:", employeeAddress);
    await contract.methods.confirmEmploymentStatus(employeeAddress).send({ from: connectedWalletAddress });
    console.log("Employment status confirmed for employee address:", employeeAddress);
    getEmployeeInformation(); // Refresh employee data after confirmation
  } catch (error) {
    console.error('Error confirmEmploymentStatus:', error);
  }
}

function getEmployeeStatus(status) {
  switch (parseInt(status)) {
    case 0:
      return 'Pending Confirmation';
    case 1:
      return 'Confirmed but not enough payments';
    case 2:
      return 'Eligible for claim';
    case 3:
      return 'Claim submitted';
    case 4:
      return 'Claimed or exited';
    default:
      return 'Others';
  }
}

onMounted(() => {
  if (web3Provider.web3) {
    getEmployeeInformation();
  }
});
</script>