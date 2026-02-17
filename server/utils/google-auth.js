import { google } from 'googleapis';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { createInterface } from 'readline';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import config from './config.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOKENS_PATH = resolve(__dirname, '..', 'google-tokens.json');
const SCOPES = [
  'https://www.googleapis.com/auth/calendar.readonly',
  'https://www.googleapis.com/auth/photoslibrary.readonly',
];

let authClient = null;

export async function getAuthClient() {
  if (authClient) return authClient;

  const credPath = resolve(__dirname, '..', config.google?.credentials || 'google-credentials.json');
  if (!existsSync(credPath)) {
    console.warn('Google credentials file not found at', credPath);
    console.warn('Calendar and Photos modules will be disabled.');
    console.warn('To enable: download OAuth2 client JSON from Google Cloud Console.');
    return null;
  }

  const creds = JSON.parse(readFileSync(credPath, 'utf-8'));
  const { client_id, client_secret, redirect_uris } = creds.installed || creds.web;

  const oauth2 = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);

  if (existsSync(TOKENS_PATH)) {
    const tokens = JSON.parse(readFileSync(TOKENS_PATH, 'utf-8'));
    oauth2.setCredentials(tokens);

    oauth2.on('tokens', (newTokens) => {
      const merged = { ...tokens, ...newTokens };
      writeFileSync(TOKENS_PATH, JSON.stringify(merged, null, 2));
    });

    authClient = oauth2;
    return authClient;
  }

  // First-time setup
  const authUrl = oauth2.generateAuthUrl({ access_type: 'offline', scope: SCOPES });
  console.log('\n========================================');
  console.log('GOOGLE AUTH SETUP (one-time)');
  console.log('========================================');
  console.log('Visit this URL to authorize JBTV:\n');
  console.log(authUrl);
  console.log('\nPaste the authorization code below:\n');

  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const code = await new Promise(r => rl.question('Code: ', r));
  rl.close();

  const { tokens } = await oauth2.getToken(code);
  oauth2.setCredentials(tokens);
  writeFileSync(TOKENS_PATH, JSON.stringify(tokens, null, 2));
  console.log('Tokens saved. Google auth is ready.\n');

  oauth2.on('tokens', (newTokens) => {
    const merged = { ...tokens, ...newTokens };
    writeFileSync(TOKENS_PATH, JSON.stringify(merged, null, 2));
  });

  authClient = oauth2;
  return authClient;
}
