<script setup>
import { ref, onMounted } from 'vue';

import Web3 from 'web3';
import { web3Provider, contract } from './utils/web3Provider'; // Assumed global state for Web3
import Login from './view/Login.vue';
import HR from './view/HR.vue';
import ChangeTheme from './components/ChangeTheme.vue';
import contractABI from "./contract/contractABI.json";
import { contractAddress } from "./contract/contractConstants.js";
import { ElMessage } from 'element-plus'
let loadingMsg

// Reactive references for account and web3 instance
const account = ref(null);

// Initialization and account setup
const initWeb3 = async () => {
  if (window.ethereum) {
    web3Provider.web3 = new Web3(window.ethereum);
    try {
      await window.ethereum.request({ method: 'eth_requestAccounts' });
      account.value = (await web3Provider.web3.eth.getAccounts())[0];
    } catch (error) {
      console.error('User denied account access');
    }
  } else if (window.web3) {
    web3Provider.web3 = new Web3(window.web3.currentProvider);
    account.value = (await web3Provider.web3.eth.getAccounts())[0];
  } else {
    const str = 'Non-Ethereum browser detected. You should install MetaMask!'
    alert(str)
    console.error(str);
  }
  contract.data = web3Provider.web3 ? new web3Provider.web3.eth.Contract(contractABI, contractAddress) : null

  if (!contract.data?.methods) return
  await checkEmployeeRegistered()
};

const connectWallet = async () => {
  if (!web3Provider.web3) {
    await initWeb3();
  }
  if (web3Provider.web3) {
    try {
      await window.ethereum.send('eth_requestAccounts');
      account.value = (await web3Provider.web3.eth.getAccounts())[0];
    } catch (error) {
      console.error('User denied account access', error);
    }
  }
};



import { useRouter } from 'vue-router'
const router = useRouter()
const navBarStatus = ref('')

function handleStatusChange(val) {
  navBarStatus.value = val
}
async function checkEmployeeRegistered() {
  try {
    // Get connected wallet address
    const accounts = await web3Provider.web3.eth.requestAccounts()
    const connectedWalletAddress = accounts[0]
    if (!contract.data?.methods) return

    // Check if employee is registered
    const userType = await contract.data.methods.getAddressIdentity().call({ from: connectedWalletAddress })
    if (userType === 'employee') {
      console.log('user type is employee')
      const employeeInfo = await contract.data.methods.getEmployeeInfo(connectedWalletAddress).call()
      if (employeeInfo["emailAddress"]) {

        router.push('/main')
        console.log('Employee already registered')
        navBarStatus.value = 'main'
      } else {
        console.log('Employee not registered')
        router.push('/')
        navBarStatus.value = 'login'

      }
      // Do something if employee is already registered, like displaying a message
    } else {
      router.push('/hr')
      console.log('connect wallet address is HR')
      navBarStatus.value = 'hr'
    }
  } catch (error) {
    console.error('Error checking employee registration:', error)
  }
}
// Execute checkEmployeeRegistered function when the component is mounted
if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');

  // 监听账户变化事件
  window.ethereum.on('accountsChanged', function (accounts) {
    initWeb3();
    // 处理账户变化
    console.log('Accounts changed:', accounts);
    if (accounts.length === 0) {
      console.log('Please connect to MetaMask.');
    } else {
      const account = accounts[0];
      console.log('Current account:', account);
      // 在这里你可以更新UI或进行其他操作
    }
  })
}
initWeb3();
// router.beforeEach((to, from) => {
//
// })
</script>




<template>
  <!--  <HelloWorld msg="Vite + Vue" />-->
  <div>
    <div
      :class="[navBarStatus === '' || navBarStatus === 'login' ? 'bg-opacity-0 text-primary-content' : 'bg-base-300 text-base-content']"
      class="h-12 flex justify-between items-center px-1 sm:px-5 z-100">
      <div class="whitespace-nowrap overflow-x-auto">
        Account: {{ account }}
      </div>
      <div>
        <button @click="connectWallet" v-if="!account" class="btn btn-sm btn-ghost">Connect Wallet</button>

        <change-theme></change-theme>
      </div>

    </div>
    <router-view @status-change="handleStatusChange">

    </router-view>
  </div>

</template>


<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}

.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}

.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
