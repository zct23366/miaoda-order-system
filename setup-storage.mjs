import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://occsfgsqshrhhjkzgplz.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jY3NmZ3Nxc2hyaGhqa3pncGx6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MzI0MjAyNywiZXhwIjoyMDk4ODE4MDI3fQ.c_HXVcTuXf4L7ZhsZOzMYKVB2tjZaHEYSyT5JXjNqFY'
);

async function main() {
  const buckets = ['menu-images', 'payment-qrcodes'];
  for (const name of buckets) {
    const { data, error } = await supabase.storage.createBucket(name, { public: true, fileSizeLimit: 5242880 });
    if (error && !error.message.includes('already exists')) {
      console.log(`❌ ${name}: ${error.message}`);
    } else {
      console.log(`✅ ${name} bucket ready`);
    }
  }
}

main();
