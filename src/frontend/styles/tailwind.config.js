// tailwind.config.js
module.exports = {
    content: [
      "./src/**/*.{js,jsx,ts,tsx}",
    ],
    theme: {
      extend: {
        colors: {
          'pom-black': '#000000',
          'pom-red': '#FF4B4B',
          'pom-blue': '#3b82f6',
          'pom-green': '#10b981',
          'pom-purple': '#8b5cf6',
        },
        fontFamily: {
          sans: ['Inter', 'sans-serif'],
        },
        boxShadow: {
          'card': '0 2px 5px rgba(0, 0, 0, 0.1)',
          'modal': '0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
        },
      },
    },
    plugins: [],
  };