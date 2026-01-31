/**
 * Generates config.js from environment variables (for Vercel deploy).
 * Run: node generate-config.js [outDir]
 * With no arg writes to project root; with "public" writes to public/config.js for Vercel.
 */
const fs = require('fs');
const path = require('path');

const url = process.env.SUPABASE_URL || '';
const key = process.env.SUPABASE_ANON_KEY || '';

const content = `// Generated at build time from Vercel env vars. Do not commit.
window.SUPABASE_URL = ${JSON.stringify(url)};
window.SUPABASE_ANON_KEY = ${JSON.stringify(key)};
`;

const outDir = process.argv[2] || __dirname;
const outPath = path.join(outDir, 'config.js');
fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(outPath, content, 'utf8');
console.log('config.js generated from SUPABASE_URL and SUPABASE_ANON_KEY');
