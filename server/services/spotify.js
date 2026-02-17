import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import { createServer } from 'http';
import config from '../utils/config.js';
import cache from '../utils/cache.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOKENS_PATH = resolve(__dirname, '..', 'spotify-tokens.json');
const API = 'https://api.spotify.com/v1';
const AUTH = 'https://accounts.spotify.com';

let tokens = null;

function loadTokens() {
  if (tokens) return tokens;
  if (existsSync(TOKENS_PATH)) {
    tokens = JSON.parse(readFileSync(TOKENS_PATH, 'utf-8'));
    return tokens;
  }
  return null;
}

function saveTokens(t) {
  tokens = t;
  writeFileSync(TOKENS_PATH, JSON.stringify(t, null, 2));
}

async function refreshAccessToken() {
  const t = loadTokens();
  if (!t?.refresh_token) return null;

  const { clientId, clientSecret } = config.spotify || {};
  const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

  const res = await fetch(`${AUTH}/api/token`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${basic}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: `grant_type=refresh_token&refresh_token=${t.refresh_token}`,
  });

  if (!res.ok) {
    console.error('Spotify refresh failed:', res.status);
    return null;
  }

  const data = await res.json();
  const updated = {
    ...t,
    access_token: data.access_token,
    expires_at: Date.now() + data.expires_in * 1000,
    ...(data.refresh_token && { refresh_token: data.refresh_token }),
  };
  saveTokens(updated);
  return updated.access_token;
}

async function getAccessToken() {
  const t = loadTokens();
  if (!t) return null;
  if (Date.now() < (t.expires_at || 0) - 60000) return t.access_token;
  return refreshAccessToken();
}

async function spotifyGet(path) {
  const token = await getAccessToken();
  if (!token) return null;

  const res = await fetch(`${API}${path}`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (res.status === 204) return null;
  if (!res.ok) {
    if (res.status === 401) {
      // Token expired, try refresh once
      const newToken = await refreshAccessToken();
      if (!newToken) return null;
      const retry = await fetch(`${API}${path}`, {
        headers: { Authorization: `Bearer ${newToken}` },
      });
      if (!retry.ok || retry.status === 204) return null;
      return retry.json();
    }
    return null;
  }
  return res.json();
}

export async function getSpotify() {
  if (!config.spotify?.clientId) {
    return { nowPlaying: null, recentTracks: [] };
  }

  // Now playing (short cache)
  let nowPlaying = cache.get('spotify:now');
  if (!nowPlaying) {
    const np = await spotifyGet('/me/player/currently-playing');
    if (np?.item) {
      nowPlaying = {
        name: np.item.name,
        artist: np.item.artists.map(a => a.name).join(', '),
        albumName: np.item.album.name,
        albumArt: np.item.album.images.find(i => i.width <= 300)?.url || np.item.album.images[0]?.url,
        isPlaying: np.is_playing,
        progressMs: np.progress_ms,
        durationMs: np.item.duration_ms,
      };
    } else {
      nowPlaying = null;
    }
    cache.set('spotify:now', nowPlaying, 30 * 1000);
  }

  // Recent tracks (longer cache)
  let recentTracks = cache.get('spotify:recent');
  if (!recentTracks) {
    const recent = await spotifyGet('/me/player/recently-played?limit=5');
    recentTracks = (recent?.items || []).map(item => ({
      name: item.track.name,
      artist: item.track.artists.map(a => a.name).join(', '),
      albumArt: item.track.album.images.find(i => i.width <= 300)?.url || item.track.album.images[0]?.url,
      playedAt: item.played_at,
    }));
    cache.set('spotify:recent', recentTracks, 2 * 60 * 1000);
  }

  return { nowPlaying, recentTracks };
}

// First-time auth setup — call this manually: node -e "import('./services/spotify.js').then(m => m.authorize())"
export async function authorize() {
  const { clientId, clientSecret, redirectPort } = config.spotify;
  const redirectUri = `http://localhost:${redirectPort || 8889}/callback`;
  const scopes = 'user-read-currently-playing user-read-recently-played';

  const authUrl = `${AUTH}/authorize?response_type=code&client_id=${clientId}&scope=${encodeURIComponent(scopes)}&redirect_uri=${encodeURIComponent(redirectUri)}`;

  console.log('\n========================================');
  console.log('SPOTIFY AUTH SETUP (one-time)');
  console.log('========================================');
  console.log('Visit this URL to authorize JBTV:\n');
  console.log(authUrl);

  return new Promise((resolvePromise) => {
    const server = createServer(async (req, res) => {
      const url = new URL(req.url, `http://localhost:${redirectPort || 8889}`);
      const code = url.searchParams.get('code');
      if (!code) {
        res.end('No code received');
        return;
      }

      const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
      const tokenRes = await fetch(`${AUTH}/api/token`, {
        method: 'POST',
        headers: {
          Authorization: `Basic ${basic}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `grant_type=authorization_code&code=${code}&redirect_uri=${encodeURIComponent(redirectUri)}`,
      });

      const data = await tokenRes.json();
      saveTokens({
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at: Date.now() + data.expires_in * 1000,
      });

      res.end('Spotify authorized! You can close this tab.');
      console.log('\nSpotify tokens saved. Auth is ready.\n');
      server.close();
      resolvePromise();
    });

    server.listen(redirectPort || 8889);
  });
}
