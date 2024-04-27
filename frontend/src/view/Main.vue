<template>
  <div class="py-5 px-7 flex flex-col bg-base-200 rounded-lg m-8">
  <div class="flex">
    <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
    <div class=" text-lg">Status</div>
  </div>
    <ul className="steps mx-10 steps-vertical sm:steps-horizontal">
      <li className="step step-primary">Register</li>
      <li className="step step-primary">HR confirmation</li>
      <li className="step">Pending</li>
      <li className="step">Active</li>
    </ul>
  </div>
  <div class="py-5 px-7 flex flex-col bg-base-200 rounded-lg m-8">
    <div class="flex">
      <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
      <div class=" text-lg">Monthly Payment</div>
    </div>
    <div class="flex flex-col items-center">
      <div class="mb-3 text-xl">6780 USDT</div>
      <div class="btn btn-sm">Confirm</div>

    </div>
  </div>
  <div class="py-5 px-7 flex flex-col bg-base-200 rounded-lg m-8">
    <div class="flex">
      <div class="bg-secondary w-2.5 rounded-lg scale-50 -translate-x-1"></div>
      <div class=" text-lg">Claim</div>
    </div>
    <div class="flex flex-col items-center">
      <div class="mb-3 text-xl">6780342 USDT</div>
      <div class="btn btn-sm">Submit Claim</div>
    </div>
  </div>
  <div class="px-7">
    <div class="btn btn-sm btn-accent">
      EXIT THE INSURANCE
    </div>
  </div>
</template>

<script>
export default {
  name: "Main"
}
</script>

<style scoped>

</style>