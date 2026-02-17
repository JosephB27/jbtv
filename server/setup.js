// Interactive setup wizard for JBTV
// Usage: node setup.js

import { readFileSync, writeFileSync, existsSync, copyFileSync } from 'fs';
import { createInterface } from 'readline';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const configPath = resolve(__dirname, 'config.json');
const examplePath = resolve(__dirname, 'config.example.json');

const rl = createInterface({ input: process.stdin, output: process.stdout });
const ask = (q) => new Promise(r => rl.question(q, r));

console.log('\n========================================');
console.log('   JBTV Setup Wizard');
console.log('========================================\n');

let config;
if (existsSync(configPath)) {
  config = JSON.parse(readFileSync(configPath, 'utf-8'));
  console.log('Found existing config.json. Updating...\n');
} else {
  config = JSON.parse(readFileSync(examplePath, 'utf-8'));
  console.log('Creating new config.json from template...\n');
}

// User name
const name = await ask(`Your name [${config.user?.name || 'Joseph'}]: `);
if (name.trim()) config.user.name = name.trim();

// Weather
console.log('\n--- Weather (OpenWeatherMap) ---');
console.log('Get a free API key at: https://openweathermap.org/api\n');
const weatherKey = await ask(`API Key [${config.weather?.apiKey === 'YOUR_OPENWEATHERMAP_KEY' ? 'not set' : 'set'}]: `);
if (weatherKey.trim()) config.weather.apiKey = weatherKey.trim();

const lat = await ask(`Latitude [${config.weather?.lat || '0.0'}]: `);
if (lat.trim()) config.weather.lat = parseFloat(lat.trim());

const lon = await ask(`Longitude [${config.weather?.lon || '0.0'}]: `);
if (lon.trim()) config.weather.lon = parseFloat(lon.trim());

// Spotify
console.log('\n--- Spotify ---');
console.log('Create an app at: https://developer.spotify.com/dashboard');
console.log('Set redirect URI to: http://localhost:8889/callback\n');
const spotifyId = await ask(`Client ID [${config.spotify?.clientId === 'YOUR_SPOTIFY_CLIENT_ID' ? 'not set' : 'set'}]: `);
if (spotifyId.trim()) config.spotify.clientId = spotifyId.trim();

const spotifySecret = await ask(`Client Secret [${config.spotify?.clientSecret === 'YOUR_SPOTIFY_CLIENT_SECRET' ? 'not set' : 'set'}]: `);
if (spotifySecret.trim()) config.spotify.clientSecret = spotifySecret.trim();

// Sports teams
console.log('\n--- Sports ---');
console.log('Supported leagues: nba, nfl, mlb, nhl, mls, epl, laliga');
const teamsInput = await ask(`Teams (e.g., "nba:lakers, nfl:rams") [${config.sports?.teams?.map(t => t.league + ':' + t.team).join(', ') || 'none'}]: `);
if (teamsInput.trim()) {
  config.sports.teams = teamsInput.split(',').map(t => {
    const [league, team] = t.trim().split(':');
    return { league: league.trim(), team: team.trim() };
  });
}

// Tickers
console.log('\n--- Stock & Crypto Tickers ---');
const stocks = await ask(`Stocks (comma-separated, e.g., "AAPL,TSLA,NVDA") [${config.tickers?.stocks?.join(',') || 'none'}]: `);
if (stocks.trim()) config.tickers.stocks = stocks.split(',').map(s => s.trim().toUpperCase());

const crypto = await ask(`Crypto (comma-separated, e.g., "bitcoin,ethereum") [${config.tickers?.crypto?.join(',') || 'none'}]: `);
if (crypto.trim()) config.tickers.crypto = crypto.split(',').map(s => s.trim().toLowerCase());

// Countdowns
console.log('\n--- Countdowns ---');
console.log('Current:', config.countdowns?.map(c => `${c.label} (${c.date})`).join(', ') || 'none');
const addCountdown = await ask('Add a countdown? (label:YYYY-MM-DD or press Enter to skip): ');
if (addCountdown.trim()) {
  const [label, date] = addCountdown.split(':').map(s => s.trim());
  if (label && date) {
    config.countdowns = config.countdowns || [];
    config.countdowns.push({ label, date });
  }
}

// News feeds
console.log('\n--- News RSS Feeds ---');
console.log('Current feeds:', config.news?.feeds?.length || 0);
const newsFeeds = await ask('RSS feed URLs (comma-separated) or Enter to keep current: ');
if (newsFeeds.trim()) {
  config.news.feeds = newsFeeds.split(',').map(s => s.trim());
}

// Port
const port = await ask(`\nServer port [${config.server?.port || 8888}]: `);
if (port.trim()) config.server.port = parseInt(port.trim());

// Save
writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('\n✓ Config saved to config.json');
console.log('\nNext steps:');
console.log('  1. For Google Calendar/Photos: Place your OAuth2 credentials JSON as google-credentials.json');
console.log('  2. Run the server: npm start');
console.log('  3. For Spotify: Run node -e "import(\'./services/spotify.js\').then(m => m.authorize())"');
console.log('  4. Package and deploy to Roku: cd ../tools && bash package.sh && bash deploy.sh <ROKU_IP> <PASSWORD>\n');

rl.close();
