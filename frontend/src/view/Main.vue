<template>
  <div class="py-5 px-7 flex flex-col bg-base-200 rounded-lg m-8">
  <div class="flex">
    <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
    <div class=" text-lg">Employee Info & Status</div>
  </div>
    <div class="w-full ">
      <div class="w-full flex flex-wrap   mt-3 mb-5">
          <div v-for="(value,key) in employeeInfoDisplay" :key="key" class="w-full sm:w-1/2 xl:w-1/3 justify-between">
            {{key + ' : ' + value}}
          </div>

      </div>
      <div v-if="withinThreeMonthsStatus === 'exit'">
        <div class="text-error font-bold text-lg">
          You have not paid your insurance premiums for over three months, and have been removed from the insurance plan!
        </div>
      </div>
      <ul className="steps mt-8 mx-10 steps-vertical sm:steps-horizontal">
        <li v-for="(item,index) in statusList" :key="index" :class="{ 'step-primary' : index < employeeInfo.data.status && withinThreeMonthsStatus !== 'exit' }" class="step">{{item }}</li>
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
          <div @click="handleMonthlyPayment" :class="{'btn-disabled': (employeeInfo.data.status !== 3 && employeeInfo.data.status !== 4) || withinThreeMonthsStatus !== 'overdue' || withinThreeMonthsStatus !== 'available' }" class="btn btn-sm my-2">Confirm</div>
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
          <div @click="handleClaim" :class="{'btn-disabled': employeeInfo.data.status !== 4 || withinThreeMonthsStatus !== 'available'}" class="btn btn-sm my-2">Submit Claim</div>
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
import {ElMessage} from "element-plus";
let loadingMsg
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
    if(key === 'status' || key === 'contributionAmount' ||key === 'payout' ||key === 'registerTimestamp') continue
    if(key === 'monthsPaid') key = 'Cumulative total'
    tmp[key] = value
  }
  tmp['Insurance Expire Date'] = calculateExpiryDate.value
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
  employeeInfo.data.salary = Number(data.monthlySalary) + ' SGD'
  employeeInfo.data.monthsPaid = Number(data.monthsPaid)
  employeeInfo.data.registerTimestamp = Number(data.registerTimestamp)
  employeeInfo.data.status = Number(data.status) + 2
  employeeInfo.data.contributionAmount = Number(data.contributionAmount / BigInt(1000000000000000000))

  const erc20Contract = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABIERC20, contractAddressERC20) : null
  const balance = await erc20Contract.methods.balanceOf(connectedWalletAddress).call()
  employeeInfo.data.balance = Number(balance / BigInt(1000000000000000000)) + ' SGD'

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
  loadingMsg = ElMessage({
    message: "<div class='flex items-center'><div style='background: rgba(255,255,255,0.2)' class='w-48 md:w-96 h-1.5 overflow-hidden rounded-md'><div style='animation-timing-function:ease-in-out;animation: mymove 3s infinite' class='rounded-md opacity-75 w-48 md:w-96 h-1.5 bg-white'></div></div><div class='ml-3 flex-none'>" + 'Pending' + '</div></div>',
    type: 'info',
    duration: 0,
    dangerouslyUseHTMLString: true
  })


  try {
    const res = await erc20Contract.methods.approve(contractAddress, 10000000000000000000 * employeeInfo.data.contributionAmount).send({ from: connectedWalletAddress });
    console.log(res);

    // Check if employee is registered
    const data = await contract.data.methods.payPremium(1).send({
      from: connectedWalletAddress,
      value: 0, //1000000000000000000 * employeeInfo.data.contributionAmount,
      gas: 2000000  // 设置足够高的gas限制确保交易不会因为gas不足失败
    });

    console.log(data);
    ElMessage(({
      message: 'Payment successful',
      type: 'success'
    }))
  } catch (error) {
    ElMessage(({
      message: error,
      type: 'error'
    }))
    console.error('An error occurred:', error);
    // 处理错误，如显示错误消息或关闭加载提示
  } finally {
    loadingMsg?.close();
    await initEmployeeInfo();
  }


}
import {useRouter} from 'vue-router'
const router = useRouter()
async function exit() {
  const accounts = await web3Provider.web3.eth.requestAccounts()
  const connectedWalletAddress = accounts[0]
  // const erc20Contract = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABIERC20, contractAddressERC20) : null
  // const res = await erc20Contract.methods.faucet().send({from: connectedWalletAddress})
  // console.log(res)

  if(!contract.data?.methods) {
    contract.data = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABI, contractAddress) : null
  }
  const data = await contract.data.methods.exit().send({from: connectedWalletAddress})
  router.push('/')
  console.log(data)

}

async function handleClaim() {
  const accounts = await web3Provider.web3.eth.requestAccounts()
  const connectedWalletAddress = accounts[0]
  loadingMsg = ElMessage({
    message: "<div class='flex items-center'><div style='background: rgba(255,255,255,0.2)' class='w-48 md:w-96 h-1.5 overflow-hidden rounded-md'><div style='animation-timing-function:ease-in-out;animation: mymove 3s infinite' class='rounded-md opacity-75 w-48 md:w-96 h-1.5 bg-white'></div></div><div class='ml-3 flex-none'>" + 'Pending' + '</div></div>',
    type: 'info',
    duration: 0,
    dangerouslyUseHTMLString: true
  })
  try {
    const data = await contract.data.methods.submitClaim().send({ from: connectedWalletAddress });
    ElMessage(({
      message: 'Operation successful',
      type: 'success'
    }))
    console.log(data);
  } catch (error) {
    console.error('An error occurred while submitting the claim:', error);

    ElMessage(({
      message: error,
      type: 'error'
    }))
    // 这里可以添加更多错误处理逻辑，例如通知用户错误发生
  } finally {
    loadingMsg?.close();
    initEmployeeInfo();
    // 这里确保无论操作成功还是失败，都会执行清理和初始化操作
  }


}
const withinThreeMonthsStatus = computed(()=>{
  // return 'exit'
  if(calculateExpiryDate.value === '') return ''
  const [year,month,day] = calculateExpiryDate.value.split('-')

  // 创建给定日期的Date对象
  // 注意JavaScript中的月份是从0开始的，所以需要month - 1
  const givenDate = new Date(year, month - 1, day);

  // 获取当前日期
  const currentDate = new Date();

  // 计算两个日期的毫秒差
  const differenceInMilliseconds = currentDate - givenDate;

  // 将毫秒转换为天数（1天 = 86400000毫秒）
  const differenceInDays = differenceInMilliseconds / (1000 * 60 * 60 * 24);

  if(differenceInDays <= 0) return 'available'
  if(differenceInDays > 90) return 'exit'
  return 'overdue'


})

const calculateExpiryDate = computed(() =>{
  const registerTimestamp = employeeInfo.data.registerTimestamp
  const months = employeeInfo.data.monthsPaid


  // 创建一个日期对象从Unix时间戳
  let startDate = new Date(registerTimestamp * 1000);

  // 计算到期月份
  startDate.setMonth(startDate.getMonth() + months);

  // 格式化日期为YYYY-MM-DD
  let year = startDate.getFullYear();
  let month = startDate.getMonth() + 1; // JavaScript中月份是从0开始的
  let day = startDate.getDate();

  // 确保月和日始终是两位数字
  month = month < 10 ? '0' + month : month;
  day = day < 10 ? '0' + day : day;
  if(isNaN(year) || isNaN(month)) return ''

  return `${year}-${month}-${day}`;
})


</script>

<style scoped>

</style>