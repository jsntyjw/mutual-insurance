<template>
  <div
      class="fixed left-0 -z-10 h-full w-full top-0 from-primary flex to-secondary text-primary-content items-end bg-gradient-to-br"

  >
    <svg
        class="fill-secondary col-start-1 row-start-1 h-auto w-full"
        width="1600"
        height="495"
        viewBox="0 0 1600 495"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
    >
      <path
          d="M0 338L53.3 349.2C106.7 360.3 213.3 382.7 320 393.8C426.7 405 533.3 405 640 359.3C746.7 313.7 853.3 222.3 960 189.2C1066.7 156 1173.3 181 1280 159.2C1386.7 137.3 1493.3 68.7 1546.7 34.3L1600 0V595H1546.7C1493.3 595 1386.7 595 1280 595C1173.3 595 1066.7 595 960 595C853.3 595 746.7 595 640 595C533.3 595 426.7 595 320 595C213.3 595 106.7 595 53.3 595H0V338Z"
      />
    </svg>
  </div>
  <div class="flex w-full h-full">
    <div class="justify-center hidden md:flex flex-1 md:pt-12">
      <div class="translate-x-3 text-primary-content ">
        <h1 class=" font-nun font-extrabold normal-case text-6xl">
          Mutual Insurance
        </h1>
        <h2 class="font-title text-lg font-extrabold sm:text-xl lg:text-2xl">
          Secure and Transparent Mutual Insurance on Blockchain
        </h2>


        <div class="mt-12 flex flex-col text-left">
          <div class="font-bold text-lg">Your Monthly Premium Contributions</div>
          <ul class="list-disc pl-5">
            <li>Tier 1 (Monthly Salary up to $2,000): $20 per month</li>
            <li>Tier 2 (Monthly Salary $2,001 - $5,000): $40 per month</li>
            <li>Tier 3 (Monthly Salary $5,001 - $10,000): $60 per month</li>
            <li>Tier 4 (Monthly Salary above $10,000): $80 per month</li>
          </ul>
        </div>

        <div class="mt-12 flex flex-col text-left">
          <div class="font-bold text-lg">Payout Plan</div>
          <ul class="list-disc pl-5">
            <li>Tier 1: 50% of the participant's average monthly salary, capped at $1,000 per month</li>
            <li>Tier 2: 40% of the participant's average monthly salary, capped at $2,000 per month</li>
            <li>Tier 3: 30% of the participant's average monthly salary, capped at $3,000 per month</li>
            <li>Tier 4: 20% of the participant's average monthly salary, capped at $4,000 per month</li>
          </ul>
        </div>



      </div>

    </div>
    <div class="flex flex-1 items-start justify-center pt-5 md:pt-12 mb-6">
      <div class="md:-translate-x-4 card w-11/12 max-w-sm md:max-w-xs lg:max-w-md glass p-5 pb-7">
        <div class="tabs">
          <a
              class="font-bold mb-2 px-1 tab tab-lg tab-lifted tab-border-none"
          >{{ 'Sign Up' }}
          </a>
        </div>
        <div
            class="card flex-shrink-0 w-full shadow-2xl bg-base-100 rounded-lg"
        >
          <div class="w-full card-body p-5 pt-2 pb-7">
            <div class="form-control">
              <label class="label">
                <span class="isRequired label-text capitalize">{{'NRIC'}}</span>
              </label>
              <input :placeholder="'Please input your NRIC'" class="input input-bordered">
            </div>
            <div class="form-control">
              <label class="label">
                <span class="isRequired label-text capitalize">{{'Name'}}</span>
              </label>
              <input  :placeholder="'Please input your name'" class="input input-bordered">
            </div>
            <div class="form-control">
              <label class="label">
                <span class="isRequired label-text capitalize">{{'Email'}}</span>
              </label>
              <input type="email" :placeholder="'Please input your email'" class="input input-bordered">
            </div>

            <div class="form-control">
              <label class="label">
                <span class="isRequired label-text capitalize">{{'Company'}}</span>
              </label>
              <input type="email" :placeholder="'Please input your company'" class="input input-bordered">
            </div>

            <div class="form-control">
              <label class="label">
                <span class="isRequired label-text capitalize">{{'Salary'}}</span>
              </label>
              <input type="number" :placeholder="'Please input your salary (USD)'" class="input input-bordered">
            </div>
            <div class="form-control mt-6">
              <button class="btn btn-primary"  > {{ 'Submit' }}</button>
            </div>
          </div>
        </div>
      </div>
      <div />
    </div>
  </div>
</template>
