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

// Hard requirement — only the user name
if (!config.user?.name || String(config.user.name).startsWith('YOUR_')) {
  console.error('ERROR: Missing config "user.name" — set your display name in config.json');
  process.exit(1);
}

// Soft requirements — warn but don't crash
const optional = [
  ['weather.apiKey', 'Weather module disabled. Get a free key at https://openweathermap.org/api'],
  ['weather.lat', 'Weather module disabled. Set your latitude.'],
  ['weather.lon', 'Weather module disabled. Set your longitude.'],
  ['spotify.clientId', 'Spotify module disabled. Set up at https://developer.spotify.com/dashboard'],
  ['google.credentials', 'Calendar & Photos modules disabled. Set up Google OAuth.'],
];

const missing = new Set();
for (const [path, hint] of optional) {
  const keys = path.split('.');
  let val = config;
  for (const k of keys) val = val?.[k];
  if (val === undefined || val === null || val === '' || String(val).startsWith('YOUR_')) {
    const module = path.split('.')[0];
    if (!missing.has(module)) {
      console.warn(`WARN: ${hint}`);
      missing.add(module);
    }
  }
}

// Defaults
config.weather ??= {};
config.weather.units ??= 'imperial';
config.news ??= { feeds: [], maxItems: 5 };
config.news.maxItems ??= 5;
config.countdowns ??= [];
config.sports ??= { teams: [] };
config.tickers ??= { stocks: [], crypto: [] };
config.photos ??= { albumName: 'Favorites', rotateIntervalSeconds: 45 };
config.server ??= { port: 8888 };
config.server.port ??= 8888;
config.spotify ??= {};
config.google ??= {};

export default config;
