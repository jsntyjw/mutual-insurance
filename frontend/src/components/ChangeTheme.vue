<template>
  <div title="Change Theme" class="dropdown dropdown-end">
    <div tabindex="0" class="btn gap-1 normal-case btn-ghost btn-sm" @click="setBlur()" @blur="handleBlur()">
      <span class="inline text-md">{{ 'THEME' }}</span>
    </div>
    <div
      :class="[isOpac?'opacity-0-imp':'']"
      class="dropdown-content bg-base-200 text-base-content rounded-t-box rounded-b-box top-px max-h-96 h-[70vh] w-52 overflow-y-auto shadow-2xl mt-16"
    >
      <div class="grid grid-cols-1 gap-3 p-3" tabindex="0">
        <div
          v-for="(item, index) in themeList"
          :key="index"
          :class="[item===currentTheme? outlineCss:'']"
          class="outline-base-content overflow-hidden rounded-lg"
          :data-set-theme="item"
          data-act-class="outline"
          @click="currentTheme = item"
        >
          <div :data-theme="item" class="bg-base-100 text-base-content w-full cursor-pointer font-sans">
            <div class="grid grid-cols-5 grid-rows-3">
              <div class="col-span-5 row-span-3 row-start-1 flex gap-1 py-3 px-4">
                <div class="flex-grow text-sm font-bold">{{ item }}</div>
                <div class="flex flex-shrink-0 flex-wrap gap-1">
                  <div class="bg-primary w-2 rounded" />
                  <div class="bg-secondary w-2 rounded" />
                  <div class="bg-accent w-2 rounded" />
                  <div class="bg-neutral w-2 rounded" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useBlur } from '../utils/dropdown.js'
// @ts-ignore
const { isOpac, handleBlur, closeDropDown, setBlur } = useBlur()
import { ref, watch } from 'vue'
const outlineCss: string[] = ['outline', 'outline-2', 'outline-offset-2']

const currentTheme = ref(document.getElementsByTagName('html')[0].getAttribute('data-theme'))
const themeList: string[] = [
  'light', 'night', 'bumblebee', 'valentine', 'aqua', 'pastel',
  'dracula', 'cmyk', 'autumn', 'business', 'acid', 'lemonade', 'winter', 'dark'
]
watch(currentTheme, (newTheme) => {
  localStorage.setItem('theme', newTheme)
  document.getElementsByTagName('html')[0].setAttribute('data-theme',
    newTheme)
})
currentTheme.value = localStorage.getItem('theme')

</script>

<style scoped>
.dropdown-content::-webkit-scrollbar {/*隐藏滚轮*/
  display: none;
  /*color:green*/
  /*background-color:black;*/
  /*@apply bg-base-200*/
}
</style>
