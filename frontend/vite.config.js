import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(() => {
  return {
    build: {
      outDir: 'build',
    },
    // https://github.com/vitejs/vite/issues/1973#issuecomment-787571499
    define: {
        'process.env': {},
    },
    plugins: [react()],
  };
});
