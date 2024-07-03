/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/obsidian_tears_frontend/src/**/*.{ts,tsx,jsx,html,js}"],
  theme: {
    fontFamily: {
      raleway: ["Raleway", "ui-sans-serif"],
      mochiy: ["Mochiy Pop P One", "ui-sans-serif"],
      jura: ["Jura", "ui-sans-serif"],
    },
    extend: {
      colors: {
        "regal-blue": "#081F31",
        "button-brown": "#945D52",
        "card-gray": "#5A656B",
        "card-beige": "#ADA284",
      },
    },
  },
  plugins: [],
};
