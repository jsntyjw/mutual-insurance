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
    <el-table :data="pendingConfirmationEmployees" style="width: 100%">
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
          <el-button @click="confirmEmploymentStatus(scope.row.walletAddress)">Verify</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="flex mb-4 mt-8">
      <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
      <div class="font-bold text-xl">Unemployment Verification</div>
    </div>
    <el-table :data="claimSubmittedEmployees" style="width: 100%">
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
          <el-button @click="confirmClaim(scope.row.walletAddress)">Verify</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import {ElTable, ElTableColumn, ElButton, ElMessage} from 'element-plus';
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

const pendingConfirmationEmployees = computed(() => {
  console.log("filteredEmployees" + maskedEmployeeData.value)
  const filteredEmployees = maskedEmployeeData.value.filter(employee => getEmployeeStatus(employee.status) === 'Pending HR Comfirmation');
  console.log('Pending Confirmation Employees:', filteredEmployees);
  return filteredEmployees;
});

const claimSubmittedEmployees = computed(() => {
  const filteredEmployees = maskedEmployeeData.value.filter(employee => getEmployeeStatus(employee.status) === 'Claim Submitted');
  console.log('Claim Submitted Employees:', filteredEmployees);
  return filteredEmployees;
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
      console.log("employeeInformation:", employeeInformation);
      employeeData.value = employeeInformation;
    } else {
      console.log('No employee information fetched');
    }
  } catch (error) {
    console.error('Error getEmployeeInformation:', error);
  }
}
let loadingMsg
async function confirmEmploymentStatus(employeeAddress) {
  try {
    const accounts = await web3Provider.web3.eth.requestAccounts();
    const connectedWalletAddress = accounts[0];
    console.log("Confirming employment status for employee address:", employeeAddress);
    loadingMsg = ElMessage({
      message: "<div class='flex items-center'><div style='background: rgba(255,255,255,0.2)' class='w-48 md:w-96 h-1.5 overflow-hidden rounded-md'><div style='animation-timing-function:ease-in-out;animation: mymove 3s infinite' class='rounded-md opacity-75 w-48 md:w-96 h-1.5 bg-white'></div></div><div class='ml-3 flex-none'>" + 'Pending' + '</div></div>',
      type: 'info',
      duration: 0,
      dangerouslyUseHTMLString: true
    })
    await contract.methods.confirmEmploymentStatus(employeeAddress).send({ from: connectedWalletAddress });
    console.log("Employment status confirmed for employee address:", employeeAddress);
    loadingMsg.close()
    ElMessage(({
      message: 'Operation successful',
      type: 'success'
    }))
    getEmployeeInformation(); // Refresh employee data after confirmation
  } catch (error) {
    loadingMsg.close()
    ElMessage(({
      message: error,
      type: 'error'
    }))
    console.error('Error confirmEmploymentStatus:', error);
  }
}

async function confirmClaim(employeeAddress) {
  try {
    const accounts = await web3Provider.web3.eth.requestAccounts();
    const connectedWalletAddress = accounts[0];
    console.log("Confirming claim for employee address:", employeeAddress);
    loadingMsg = ElMessage({
      message: "<div class='flex items-center'><div style='background: rgba(255,255,255,0.2)' class='w-48 md:w-96 h-1.5 overflow-hidden rounded-md'><div style='animation-timing-function:ease-in-out;animation: mymove 3s infinite' class='rounded-md opacity-75 w-48 md:w-96 h-1.5 bg-white'></div></div><div class='ml-3 flex-none'>" + 'Pending' + '</div></div>',
      type: 'info',
      duration: 0,
      dangerouslyUseHTMLString: true
    })
    await contract.methods.confirmClaim(employeeAddress).send({ from: connectedWalletAddress });
    loadingMsg.close()
    ElMessage(({
      message: 'Operation successful',
      type: 'success'
    }))
    console.log("Claim confirmed for employee address:", employeeAddress);
    getEmployeeInformation(); // Refresh employee data after confirmation
  } catch (error) {
    loadingMsg.close()
    ElMessage(({
      message: error,
      type: 'error'
    }))
    console.error('Error confirmClaim:', error);
  }
}

function getEmployeeStatus(status) {
  console.log('status is: ' + status)
  switch (parseInt(status)) {
    case 0:
      return 'Unregistered';
    case 1:
      return 'Pending HR Comfirmation';
    case 2:
      return 'Waiting Period';
    case 3:
      return 'Active';
    case 4:
      return 'Claim Submitted';
    case 5:
      return 'Claim Comfirmed';
    case 6:
      return 'Terminated';
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