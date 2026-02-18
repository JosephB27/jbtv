import { Router } from 'express';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import config from '../utils/config.js';

const router = Router();
const __dirname = dirname(fileURLToPath(import.meta.url));
const TOKENS_PATH = resolve(__dirname, '..', 'spotify-tokens.json');
const AUTH = 'https://accounts.spotify.com';

// GET /api/spotify/auth — redirects browser to Spotify authorization page
router.get('/auth', (req, res) => {
  const { clientId } = config.spotify || {};
  if (!clientId) {
    return res.status(400).send('Spotify clientId not configured in config.json');
  }

  const port = config.server.port;
  const redirectUri = `http://127.0.0.1:${port}/api/spotify/callback`;
  const scopes = 'user-read-currently-playing user-read-recently-played';

  const url = `${AUTH}/authorize?response_type=code&client_id=${clientId}&scope=${encodeURIComponent(scopes)}&redirect_uri=${encodeURIComponent(redirectUri)}`;
  res.redirect(url);
});

// GET /api/spotify/callback — Spotify redirects here after user approves
router.get('/callback', async (req, res) => {
  const { code, error } = req.query;

  if (error) {
    return res.status(400).send(`Authorization denied: ${error}`);
  }
  if (!code) {
    return res.status(400).send('No authorization code received');
  }

  const { clientId, clientSecret } = config.spotify || {};
  const port = config.server.port;
  const redirectUri = `http://127.0.0.1:${port}/api/spotify/callback`;
  const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

  try {
    const tokenRes = await fetch(`${AUTH}/api/token`, {
      method: 'POST',
      headers: {
        Authorization: `Basic ${basic}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: `grant_type=authorization_code&code=${code}&redirect_uri=${encodeURIComponent(redirectUri)}`,
    });

    if (!tokenRes.ok) {
      const err = await tokenRes.text();
      return res.status(500).send(`Token exchange failed: ${err}`);
    }

    const data = await tokenRes.json();
    const tokens = {
      access_token: data.access_token,
      refresh_token: data.refresh_token,
      expires_at: Date.now() + data.expires_in * 1000,
    };

    writeFileSync(TOKENS_PATH, JSON.stringify(tokens, null, 2));
    console.log('Spotify tokens saved successfully.');

    res.send(`
      <html>
      <body style="background:#111;color:#fff;font-family:system-ui;display:flex;align-items:center;justify-content:center;height:100vh;margin:0">
        <div style="text-align:center">
          <h1 style="color:#00D4AA">Spotify Connected</h1>
          <p>JBTV will now show your music. You can close this tab.</p>
        </div>
      </body>
      </html>
    `);
  } catch (err) {
    console.error('Spotify auth error:', err);
    res.status(500).send(`Auth failed: ${err.message}`);
  }
});

// GET /api/spotify/status — check if Spotify is authorized
router.get('/status', (req, res) => {
  const hasTokens = existsSync(TOKENS_PATH);
  res.json({ authorized: hasTokens });
});

export default router;
