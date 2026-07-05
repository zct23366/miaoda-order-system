import { execSync } from 'child_process';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
process.chdir(__dirname);

const vc = join(__dirname, 'node_modules', 'vercel', 'dist', 'vc.js');

try {
  // First try promoting
  console.log('=== Promoting to production ===');
  let result = execSync(`"${process.execPath}" "${vc}" promote --yes`, {
    encoding: 'utf8', stdio: 'pipe', timeout: 60000,
    env: { ...process.env, FORCE_COLOR: '1' }
  });
  console.log(result);
} catch (e) {
  console.log('Promote stdout:', e.stdout);
  console.log('Promote stderr:', e.stderr);
}

try {
  // List deployments
  console.log('=== Deployments ===');
  let result = execSync(`"${process.execPath}" "${vc}" ls`, {
    encoding: 'utf8', stdio: 'pipe', timeout: 30000,
    env: { ...process.env, FORCE_COLOR: '1' }
  });
  console.log(result);
} catch (e) {
  console.log('List stdout:', e.stdout);
  console.log('List stderr:', e.stderr);
}
