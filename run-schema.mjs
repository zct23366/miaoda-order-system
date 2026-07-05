import { readFileSync } from 'fs';
import pg from 'pg';

const { Client } = pg;

const PASSWORD = 'NK8wca5CqzW3syPr';
const PROJECT = 'occsfgsqshrhhjkzgplz';
const REGION = 'ap-northeast-1';

const connStrs = [
  `postgresql://postgres.${PROJECT}:${PASSWORD}@aws-0-${REGION}.pooler.supabase.com:5432/postgres`,
  `postgresql://postgres.${PROJECT}:${PASSWORD}@aws-0-${REGION}.pooler.supabase.com:6543/postgres`,
  `postgresql://postgres.${PROJECT}:${PASSWORD}@db.${PROJECT}.supabase.co:5432/postgres`,
];

async function tryConnect() {
  for (const connStr of connStrs) {
    const client = new Client({ connectionString: connStr, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 10000 });
    try {
      console.log(`Trying: ${connStr.replace(PASSWORD, '***')}`);
      await client.connect();
      console.log('✅ Connected!');
      return client;
    } catch (e) {
      console.log(`  ❌ ${e.message}`);
    }
  }
  return null;
}

const client = await tryConnect();
if (!client) {
  console.error('Could not connect to any endpoint');
  process.exit(1);
}

const sql = readFileSync('./supabase/schema.sql', 'utf8');
console.log(`Executing ${sql.length} bytes of SQL...`);

try {
  await client.query(sql);
  console.log('✅ Schema executed successfully!');
} catch (e) {
  console.error('SQL error:', e.message);
  // Try statement by statement
  const statements = sql.split(';').filter(s => s.trim());
  console.log(`Retrying ${statements.length} statements individually...`);
  for (let i = 0; i < statements.length; i++) {
    const stmt = statements[i].trim();
    if (!stmt) continue;
    try {
      await client.query(stmt + ';');
      if (i % 15 === 0) process.stdout.write('.');
    } catch (err) {
      console.log(`\n  Statement ${i}: ${err.message.substring(0, 100)}`);
    }
  }
  console.log('\n✅ Done!');
}

await client.end();
