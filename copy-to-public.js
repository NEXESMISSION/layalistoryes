/**
 * Copies static site files into public/ for Vercel (so outputDirectory: "public" works).
 */
const fs = require('fs');
const path = require('path');

const root = __dirname;
const publicDir = path.join(root, 'public');

const toCopy = [
  'index.html',
  'product.html',
  'stories.html',
  'how-it-works.html',
  'gifts.html',
  'about.html',
  'contact.html',
  'pages.css',
  'NOBG.png',
];
const dirsToCopy = ['js', 'imges', 'admin', 'video'];

function copyFile(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

function copyDir(srcDir, destDir) {
  if (!fs.existsSync(srcDir)) return;
  fs.mkdirSync(destDir, { recursive: true });
  for (const name of fs.readdirSync(srcDir)) {
    const s = path.join(srcDir, name);
    const d = path.join(destDir, name);
    if (fs.statSync(s).isDirectory()) copyDir(s, d);
    else copyFile(s, d);
  }
}

if (fs.existsSync(publicDir)) {
  fs.rmSync(publicDir, { recursive: true });
}
fs.mkdirSync(publicDir, { recursive: true });

for (const file of toCopy) {
  const src = path.join(root, file);
  if (fs.existsSync(src)) copyFile(src, path.join(publicDir, file));
}
for (const dir of dirsToCopy) {
  const src = path.join(root, dir);
  copyDir(src, path.join(publicDir, dir));
}

console.log('Static files copied to public/');
