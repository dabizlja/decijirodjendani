import type { Config } from 'tailwindcss'

export default {
  content: [
    "./app/**/*.{html,html.erb,js,ts,jsx,tsx}",
    "./app/views/**/*.html.erb",
    "./node_modules/flowbite/**/*.js"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('flowbite/plugin')
  ],
} satisfies Config