/**
 * Generates config.js from environment variables (for Vercel deploy).
 * Run: node generate-config.js
 * In Vercel: set Build Command to "npm run build" and add env vars SUPABASE_URL, SUPABASE_ANON_KEY.
 */
const fs = require('fs');
const path = require('path');

const url = process.env.SUPABASE_URL || '';
const key = process.env.SUPABASE_ANON_KEY || '';

const content = `// Generated at build time from Vercel env vars. Do not commit.
window.SUPABASE_URL = ${JSON.stringify(url)};
window.SUPABASE_ANON_KEY = ${JSON.stringify(key)};
`;

const outPath = path.join(__dirname, 'config.js');
fs.writeFileSync(outPath, content, 'utf8');
console.log('config.js generated from SUPABASE_URL and SUPABASE_ANON_KEY');
