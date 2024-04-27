<script setup>
import HelloWorld from './components/HelloWorld.vue'
import Main from './view/Main.vue'
import ChangeTheme from './components/ChangeTheme.vue'
</script>

<script>
import Web3 from 'web3';

export default {
  name: 'App',
  data() {
    return {
      account: null,
      web3: null,
    };
  },
  mounted() {
    this.initWeb3();
  },
  methods: {
    async initWeb3() {
      if (window.ethereum) {
        this.web3 = new Web3(window.ethereum);
        try {
          await window.ethereum.request({ method: 'eth_requestAccounts' });
          this.account = (await this.web3.eth.getAccounts())[0];
        } catch (error) {
          console.error('User denied account access');
        }
      } else if (window.web3) {
        this.web3 = new Web3(window.web3.currentProvider);
        this.account = (await this.web3.eth.getAccounts())[0];
      } else {
        console.error('Non-Ethereum browser detected. You should install MetaMask!');
      }
    },
    async handleWalletConnection() {
      if (!this.web3) {
        await this.initWeb3();
      }
      if (this.web3) {
        try {
          await window.ethereum.send('eth_requestAccounts');
          this.account = (await this.web3.eth.getAccounts())[0];
        } catch (error) {
          console.error('User denied account access', error);
        }
      }
    },
  },
};
</script>


<template>
<!--  <HelloWorld msg="Vite + Vue" />-->
  <div>
    <div class="bg-base-300 h-12 flex justify-between items-center px-5">
      <div>
        Account: {{ account }}
      </div>
      <div>
        <button @click="connectWallet" v-if="!account">Connect Wallet</button>

        <change-theme></change-theme>
      </div>

    </div>
    <Main></Main>
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


