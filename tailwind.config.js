/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/obsidian_tears_frontend/src/**/*.{ts,tsx,jsx,html,js}"],
  theme: {
    fontFamily: {
      title: ["Raleway", "ui-sans-serif"],
    },
    extend: {
      colors: {
        "regal-blue": "#081F31",
        "button-brown": "#945D52",
      },
    },
  },
  plugins: [],
};
