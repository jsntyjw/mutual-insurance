<template>
<div class="m-8">
  <div class="flex mb-4">
    <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
    <div class="font-bold text-xl" >Employment Verification</div>
  </div>
  <el-table :data="tableData" style="width: 100%">
    <el-table-column prop="date" label="日期" width="180"/>
    <el-table-column prop="name" label="姓名" width="180"/>
    <el-table-column prop="address" label="地址"/>
  </el-table>
</div>
<div class="m-8">
  <div class="flex mb-4">
    <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
    <div class="font-bold text-xl" >Termination Verification</div>
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
