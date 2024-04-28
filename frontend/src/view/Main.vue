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
          <div class="mb-3 text-xl">{{employeeInfo.data.contributionAmount + ' SGD'}}</div>
          <div @click="handleMonthlyPayment" :class="{'btn-disabled': employeeInfo.data.status < 3}" class="btn btn-sm my-2">Confirm</div>
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
          <div class="mb-3 text-xl">{{ employeeInfo.data.payout + ' SGD' }}</div>
          <div @click="handleClaim" :class="{'btn-disabled': employeeInfo.data.status < 4}" class="btn btn-sm my-2">Submit Claim</div>
        </div>
      </div>

    </div>
  </div>
  <div class="px-7 mt-8">
    <div @click="exit" class="btn btn-sm btn-accent">
      EXIT THE INSURANCE
    </div>
  </div>
</template>

<script setup>
import {reactive,onMounted,computed} from "vue";
import {contract, web3Provider} from "../utils/web3Provider.js";
import contractABI from "../contract/contractABI.json";
import contractABIERC20 from "../contract/contractABIERC20.json";
import {contractAddress, contractAddressERC20} from "../contract/contractConstants.js";
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
  payout: 0
  }})
const employeeInfoDisplay = computed(()=>{
  const tmp = {}
  for(let key in employeeInfo.data) {
    const value = employeeInfo.data[key]
    if(key === 'status' || key === 'contributionAmount' ||key === 'payout') continue
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
  employeeInfo.data.payout = Number(data.payout / BigInt(1000000000000000000))
  employeeInfo.data.name = data.employeeName
  employeeInfo.data.NRIC = data.nric
  employeeInfo.data.email = data.emailAddress
  employeeInfo.data.salary = Number(data.monthlySalary)
  employeeInfo.data.monthsPaid = Number(data.monthsPaid)
  employeeInfo.data.status = Number(data.status) + 2
  employeeInfo.data.contributionAmount = Number(data.contributionAmount / BigInt(1000000000000000000))

}
initEmployeeInfo()
if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');

  // 监听账户变化事件
  window.ethereum.on('accountsChanged', function (accounts) {
    initEmployeeInfo()
  })
}
onMounted(async ()=>{
  // await initEmployeeInfo()
})
async function handleMonthlyPayment() {
  const accounts = await web3Provider.web3.eth.requestAccounts()
  const connectedWalletAddress = accounts[0]
  if(!contract.data?.methods) {
    contract.data = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABI, contractAddress) : null
  }
  const erc20Contract = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABIERC20, contractAddressERC20) : null
  // const maxUint256 = '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
  const res = await erc20Contract.methods.approve(contractAddress,10000000000000000000 * employeeInfo.data.contributionAmount).send({from: connectedWalletAddress})
  console.log(res)
  // Check if employee is registered
  const data = await contract.data.methods.payPremium(1).send({
    from: connectedWalletAddress,
    value: 0,//1000000000000000000 * employeeInfo.data.contributionAmount,
    gas: 2000000  // 设置足够高的gas限制确保交易不会因为gas不足失败
  })
  console.log(data)
  initEmployeeInfo()

}

async function exit() {
  const accounts = await web3Provider.web3.eth.requestAccounts()
  const connectedWalletAddress = accounts[0]
  const erc20Contract = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABIERC20, contractAddressERC20) : null
  const res = await erc20Contract.methods.faucet().send({from: connectedWalletAddress})
  // console.log(res)
  return
  if(!contract.data?.methods) {
    contract.data = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABI, contractAddress) : null
  }
  const data = await contract.data.methods.exit(connectedWalletAddress).call()
  console.log(data)

}

async function handleClaim() {
  const accounts = await web3Provider.web3.eth.requestAccounts()
  const connectedWalletAddress = accounts[0]
  const data = await contract.data.methods.submitClaim().send({ from: connectedWalletAddress })
  initEmployeeInfo()
  console.log(data)

}
</script>

<style scoped>

</style>