import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// Dev server runs outside Docker; the backend is reachable on the host
// via the BACKEND_PORT mapping (default 5000). The frontend always calls
// the relative path /api — in production nginx proxies it instead.
const BACKEND_DEV_URL = process.env.BACKEND_DEV_URL ?? 'http://localhost:5000'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: BACKEND_DEV_URL,
        changeOrigin: true,
      },
    },
  },
})
