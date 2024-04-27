<script setup>
import { ref, onMounted } from 'vue';

import Web3 from 'web3';
import { web3Provider,contract } from './utils/web3Provider'; // Assumed global state for Web3
import Login from './view/Login.vue';
import HR from './view/HR.vue';
import ChangeTheme from './components/ChangeTheme.vue';
import contractABI from "./contract/contractABI.json";
import {contractAddress} from "./contract/contractConstants.js";

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
  console.log(contract.data.methods)
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


// import {computed} from 'vue'
//
// const navBarStatus = computed(()=>{
//   if(web3Provider.web3) {
//     return 'logged'
//   }
//   else {
//     return 'not yet'
//   }
//
// })

import {useRouter} from 'vue-router'
const router = useRouter()
const navBarStatus = ref('')
async function checkEmployeeRegistered() {
  try {
    // Get connected wallet address
    const accounts = await web3Provider.web3.eth.requestAccounts()
    const connectedWalletAddress = accounts[0]

    // Check if employee is registered
    const userType = await contract.data.methods.getAddressIdentity(connectedWalletAddress).call()
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
      // Register the employee using the provided information
      // await registerEmployee()
    }
  } catch (error) {
    console.error('Error checking employee registration:', error)
  }
}
// Execute checkEmployeeRegistered function when the component is mounted
onMounted(() => {
  initWeb3();
  // Check if wallet is connected
  // console.log(web3Provider.web3, web3Provider.web3.eth.defaultAccount)
  // if (web3Provider.web3) {
  //   // Wallet is connected, check if employee is registered
  //   checkEmployeeRegistered()
  // }
})
</script>




<template>
<!--  <HelloWorld msg="Vite + Vue" />-->
  <div>
    <div :class="[navBarStatus !== 'login'?  'bg-base-300 text-base-content' :  'bg-opacity-0 text-primary-content' ]" class="h-12 flex justify-between items-center px-5">
      <div  class="whitespace-nowrap">
        Account: {{ account }}
      </div>
      <div>
        <button @click="connectWallet" v-if="!account" class="btn btn-sm btn-ghost">Connect Wallet</button>

        <change-theme></change-theme>
      </div>

    </div>
<!--    <Main></Main>-->
<!--    <Login></Login>-->
    <router-view>

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


