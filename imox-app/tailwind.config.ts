import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        imox: {
          bg: "#0A0E14",
          surface: "#131A24",
          border: "rgba(255, 255, 255, 0.08)",
          primary: "#2DD4A8",
          text: "#E6EDF3",
          secondary: "#94A3B8",
          sale: "#2DD4A8",
          rent: "#38BDF8",
          up: "#2DD4A8",
          down: "#F87171",
        },
      },
      borderRadius: {
        card: "12px",
      },
      spacing: {
        "1": "8px",
        "2": "16px",
        "3": "24px",
        "4": "32px",
        "5": "40px",
        "6": "48px",
      },
      fontFamily: {
        sans: ["var(--font-inter)", "sans-serif"],
      },
    },
  },
  plugins: [],
};
export default config;
