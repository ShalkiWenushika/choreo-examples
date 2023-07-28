import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
//import pages  from "vite-plugin-pages";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(),
    // pages({
    //   // Specify the entry HTML file
    //   pagesDir: "./src",
    //   extensions: ["html"],
    // }),
  ],
});