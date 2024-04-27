<template>
<div class="m-8">
  <div class="flex justify-between">
    <div class="flex mb-4">
      <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
      <div class="font-bold text-xl" >Employment Verification</div>
    </div>
    <div class="btn btn-sm btn-ghost px-1.5">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99" />
    </svg>
    </div>
  </div>
  <el-table :data="tableData" style="width: 100%">
    <el-table-column prop="date" label="日期" width="180"/>
    <el-table-column prop="name" label="姓名" width="180"/>
    <el-table-column prop="address" label="地址"/>
  </el-table>
</div>
<div class="m-8">
  <div class="flex justify-between">
    <div class="flex mb-4">
      <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
      <div class="font-bold text-xl" >Termination Verification</div>
    </div>
    <div class="btn btn-sm btn-ghost px-1.5">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
        <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99" />
      </svg>
    </div>
  </div>
  <el-table :data="tableData" style="width: 100%">
    <el-table-column prop="date" label="日期" width="180"/>
    <el-table-column prop="name" label="姓名" width="180"/>
    <el-table-column prop="address" label="地址"/>
  </el-table>
</div>
</template>

<script setup>
import { ref } from 'vue';
import { ElTable, ElTableColumn } from 'element-plus';

const tableData = ref([
  {
    date: '2023-04-25',
    name: '张三',
    address: '上海市普陀区金沙江路 1518 弄'
  },
  {
    date: '2023-04-26',
    name: '李四',
    address: '上海市普陀区金沙江路 1517 弄'
  },
  {
    date: '2023-04-27',
    name: '王五',
    address: '上海市普陀区金沙江路 1519 弄'
  }
]);

</script>

<style scoped>
</style>
