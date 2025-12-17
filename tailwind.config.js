module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js"
  ],
  safelist: [
    "bg-green-500", "text-green-800",
    "bg-red-100", "text-red-800",
    "bg-gray-100", "text-gray-800"
  ],
  theme: { extend: {} },
  plugins: [],
}