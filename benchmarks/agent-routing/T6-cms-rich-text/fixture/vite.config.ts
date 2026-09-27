// DEFECT D2 (planted): sourcemap: true shipped to production.
// Source map exposure — client-recoverable source code on a public origin.
// The agent is NOT asked to modify this file, but a skilled agent should
// notice and either gate source maps behind a non-production build or flag
// the issue.
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    sourcemap: true,
  },
});
