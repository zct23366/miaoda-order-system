import { build } from 'vite';
import { join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));

try {
  await build({ root: __dirname });
  console.log('Build succeeded');
} catch (e) {
  console.error('Build failed:', e.message);
  process.exit(1);
}
