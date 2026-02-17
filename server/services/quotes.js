import { readFileSync } from 'fs';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const quotesPath = resolve(__dirname, '..', 'quotes.json');

let quotes = [];
try {
  quotes = JSON.parse(readFileSync(quotesPath, 'utf-8'));
} catch {
  console.warn('quotes.json not found or invalid, quote module disabled');
}

export function getQuote() {
  if (quotes.length === 0) return { text: '', author: '' };

  // Deterministic daily selection based on date string
  const dateStr = new Date().toISOString().split('T')[0];
  let hash = 0;
  for (const ch of dateStr) hash = ((hash << 5) - hash + ch.charCodeAt(0)) | 0;

  const index = Math.abs(hash) % quotes.length;
  return quotes[index];
}
