import { readFileSync } from 'fs';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const configPath = resolve(__dirname, '..', 'config.json');

let config;
try {
  config = JSON.parse(readFileSync(configPath, 'utf-8'));
} catch (err) {
  if (err.code === 'ENOENT') {
    console.error('ERROR: server/config.json not found.');
    console.error('Copy config.example.json to config.json and fill in your API keys.');
    process.exit(1);
  }
  console.error('ERROR: Failed to parse config.json:', err.message);
  process.exit(1);
}

const required = [
  ['user.name', 'Your display name'],
  ['weather.apiKey', 'Get one free at https://openweathermap.org/api'],
  ['weather.lat', 'Your latitude (e.g., 34.0522 for LA)'],
  ['weather.lon', 'Your longitude (e.g., -118.2437 for LA)'],
];

for (const [path, hint] of required) {
  const keys = path.split('.');
  let val = config;
  for (const k of keys) val = val?.[k];
  if (val === undefined || val === null || val === '' || String(val).startsWith('YOUR_')) {
    console.error(`ERROR: Missing config "${path}" — ${hint}`);
    process.exit(1);
  }
}

// Defaults
config.weather.units ??= 'imperial';
config.news ??= { feeds: [], maxItems: 5 };
config.news.maxItems ??= 5;
config.countdowns ??= [];
config.sports ??= { teams: [] };
config.tickers ??= { stocks: [], crypto: [] };
config.photos ??= { albumName: 'Favorites', rotateIntervalSeconds: 45 };
config.server ??= { port: 8888 };
config.server.port ??= 8888;

export default config;
