<template>
  <div class="py-5 px-7 flex flex-col bg-base-200 rounded-lg m-8">
  <div class="flex">
    <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
    <div class=" text-lg">Employee Info & Status</div>
  </div>
    <div class="w-full ">
      <div class="w-full flex flex-wrap   mt-3 mb-6">
          <div v-for="(value,key) in employeeInfoDisplay" :key="key" class="w-full sm:w-1/2 xl:w-1/3 justify-between">
            {{key + ' : ' + value}}
          </div>

      </div>
      <ul className="steps mx-10 steps-vertical sm:steps-horizontal">
        <li v-for="(item,index) in statusList" :key="index" :class="{ 'step-primary' : index < employeeInfo.data.status }" class="step">{{item }}</li>
      </ul>
    </div>
  </div>
  <div class="flex flex-col sm:flex-row">
    <div class="sm:w-1/2 mb-8 sm:mb-0 pl-8 sm:mr-4 pr-8 sm:pr-0">
      <div class="flex flex-col bg-base-200 rounded-lg p-4">
        <div class="flex mb-2">
          <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
          <div class=" text-lg">Monthly Payment</div>
        </div>
        <div class="flex flex-col items-center">
          <div class="mb-3 text-xl">{{employeeInfo.data.contributionAmount + ' USD'}}</div>
          <div class="btn btn-sm my-2">Confirm</div>
        </div>
      </div>

    </div>
    <div class=" sm:w-1/2 pr-8 sm:ml-4 pl-8 sm:pl-0">
      <div class="flex flex-col bg-base-200 rounded-lg p-4">
        <div class="flex mb-2">
          <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
          <div class=" text-lg">Claim</div>
        </div>
        <div class="flex flex-col items-center">
          <div class="mb-3 text-xl">6780342 USD</div>
          <div class="btn btn-sm my-2">Submit Claim</div>
        </div>
      </div>

    </div>
  </div>
  <div class="px-7 mt-8">
    <div class="btn btn-sm btn-accent">
      EXIT THE INSURANCE
    </div>
  </div>
</template>

<script setup>
import {reactive,onMounted,computed} from "vue";
import {contract, web3Provider} from "../utils/web3Provider.js";
import contractABI from "../contract/contractABI.json";
import {contractAddress} from "../contract/contractConstants.js";
const statusList = [
  "Register",
  "Pending HR Confirmation",
  "Waiting Period (3 months)",
  "Active",
  "Claim Submitted",
  "Claim Confirmed"
]
const employeeInfo = reactive({data:{
  name: "",
  NRIC: "",
  email: "",
  salary: 0,
  monthsPaid: 0,
  contributionAmount: 0,
  status: 0,
  }})
const employeeInfoDisplay = computed(()=>{
  const tmp = {}
  for(let key in employeeInfo.data) {
    const value = employeeInfo.data[key]
    if(key === 'status' || key === 'contributionAmount') continue
    if(key === 'monthsPaid') key = 'Cumulative total'
    tmp[key] = value
  }
  return tmp
})
async function initEmployeeInfo() {
  const accounts = await web3Provider.web3.eth.requestAccounts()
  const connectedWalletAddress = accounts[0]
  if(!contract.data?.methods) {
    contract.data = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABI, contractAddress) : null
  }

  // Check if employee is registered
  const data = await contract.data.methods.getEmployeeInfo(connectedWalletAddress).call()
  console.log(data)
  employeeInfo.data.name = data.employeeName
  employeeInfo.data.NRIC = data.nric
  employeeInfo.data.email = data.emailAddress
  employeeInfo.data.salary = Number(data.monthlySalary)
  employeeInfo.data.monthsPaid = Number(data.monthsPaid)
  employeeInfo.data.status = Number(data.status) + 2
  employeeInfo.data.contributionAmount = Number(data.contributionAmount / BigInt(1000000000000000000))

}
initEmployeeInfo()
onMounted(async ()=>{
  // await initEmployeeInfo()
})
</script>

<style scoped>

</style>