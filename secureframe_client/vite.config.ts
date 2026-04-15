import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  // Add this new block right here to force Vite to process Apollo correctly
  optimizeDeps: {
    include: ['@apollo/client', 'graphql']
  }
})