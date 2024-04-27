<script setup>
import HelloWorld from './components/HelloWorld.vue'
import Main from './view/Main.vue'
import ChangeTheme from './components/ChangeTheme.vue'
function handleWalletConnection() {
  console.log('小志1')

}
</script>

<template>
<!--  <HelloWorld msg="Vite + Vue" />-->
  <div>
    <div class="bg-base-300 h-12 flex justify-between items-center px-5">
      <div>
        Account: 0xjfsdklakhfdgjfls
      </div>
      <div>
        <div @click="handleWalletConnection" class="btn btn-sm btn-ghost">Connect Wallet</div>

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
