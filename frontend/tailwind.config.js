/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [require('daisyui')],

  daisyui: {
    themes: [
      'light', 'night', 'bumblebee', 'valentine', 'aqua',
      'lofi', 'pastel',
      'dracula', 'cmyk', 'autumn', 'business', 'acid', 'lemonade', 'winter',
      'dark'
    ],

  },
}

