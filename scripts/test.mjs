import { spawnSync } from 'node:child_process';
import { readdirSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const excluded = new Set(['.git', 'dist', 'node_modules']);

function discover(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory() && !excluded.has(entry.name)) {
      files.push(...discover(path));
    } else if (entry.isFile() && entry.name.endsWith('.test.lua')) {
      files.push(relative(root, path));
    }
  }
  return files.sort();
}

const requested = process.argv.slice(2);
const files = requested.length > 0 ? requested : discover(root);
let failed = 0;
for (const file of files) {
  console.log(`\n=== ${file} ===`);
  const result = spawnSync('lua', ['-l', 'scripts.test-bootstrap', file], {
    cwd: root,
    stdio: 'inherit',
  });
  if (result.error) {
    console.error(result.error.message);
  }
  if (result.status !== 0) {
    failed += 1;
  }
}
console.log(`\nTest files: ${files.length}, passed: ${files.length - failed}, failed: ${failed}`);
process.exitCode = failed > 0 || files.length === 0 ? 1 : 0;
