<script setup>
import { ref, onMounted } from 'vue';

import Web3 from 'web3';
import { web3Provider } from './utils/web3Provider'; // Assumed global state for Web3
import Login from './view/Login.vue';
import HR from './view/HR.vue';
import ChangeTheme from './components/ChangeTheme.vue';

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

onMounted(() => {
  initWeb3();
});
import {computed} from 'vue'
const navBarStatus = computed(()=>{
  if(web3Provider.web3) {
    return 'logged'
  }
  else {
    return 'not yet'
  }

})
</script>




<template>
<!--  <HelloWorld msg="Vite + Vue" />-->
  <div>
    <div :class="[navBarStatus === 'not yet'? 'bg-opacity-0 text-primary-content' : 'bg-base-300 text-base-content']" class=" h-12 flex justify-between items-center px-5">
      <div>
        Account: {{ account }}
      </div>
      <div>
        <button @click="connectWallet" v-if="!account" class="btn btn-sm btn-ghost">Connect Wallet</button>

        <change-theme></change-theme>
      </div>

    </div>
<!--    <Main></Main>-->
<!--    <Login></Login>-->
    <HR></HR>
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


