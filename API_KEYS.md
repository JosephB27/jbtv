# JBTV API Keys Setup Guide

This guide walks you through getting every API key JBTV needs. Some modules work without any keys (clock, quotes, countdowns, news, sports, stocks/crypto). The ones below unlock the remaining modules.

---

## 1. OpenWeatherMap (Weather Module)

**What you need:** `weather.apiKey`

1. Go to [https://home.openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up)
2. Create a free account
3. After confirming your email, go to [https://home.openweathermap.org/api_keys](https://home.openweathermap.org/api_keys)
4. Copy your default API key (or generate a new one)
5. Add to `config.json`:
   ```json
   "weather": {
     "apiKey": "paste-your-key-here",
     "lat": 34.0522,
     "lon": -118.2437,
     "units": "imperial"
   }
   ```
6. Get your coordinates: Google "[your city] latitude longitude"

**Free tier:** 1,000 calls/day (JBTV uses ~48/day at 30s polling with 30min cache)

---

## 2. Spotify (Now Playing Module)

**What you need:** `spotify.clientId` and `spotify.clientSecret`

1. Go to [https://developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account
3. Click **Create App**
4. Fill in:
   - App name: `JBTV`
   - App description: `Personal dashboard`
   - Redirect URI: `http://localhost:8889/callback`
   - Check **Web API**
5. Click **Save**
6. On the app page, click **Settings**
7. Copy **Client ID** and **Client Secret**
8. Add to `config.json`:
   ```json
   "spotify": {
     "clientId": "paste-client-id",
     "clientSecret": "paste-client-secret",
     "redirectPort": 8889
   }
   ```
9. Run the auth flow once on your server laptop:
   ```bash
   cd server
   npm run auth:spotify
   ```
   This opens a browser — log in and approve. It saves a refresh token to `spotify-token.json`.

---

## 3. Google Calendar & Photos (Calendar + Photos Modules)

**What you need:** Google OAuth2 credentials file

1. Go to [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. Create a new project (or select existing) — name it `JBTV`
3. **Enable APIs:**
   - Go to [https://console.cloud.google.com/apis/library](https://console.cloud.google.com/apis/library)
   - Search for and enable: **Google Calendar API**
   - Search for and enable: **Google Photos Library API**
4. **Create OAuth consent screen:**
   - Go to [https://console.cloud.google.com/apis/credentials/consent](https://console.cloud.google.com/apis/credentials/consent)
   - Choose **External** (or Internal if using Workspace)
   - Fill in app name: `JBTV`, your email for support contact
   - Add scopes: `calendar.readonly`, `photoslibrary.readonly`
   - Add yourself as a test user
   - Click **Save**
5. **Create credentials:**
   - Go to [https://console.cloud.google.com/apis/credentials](https://console.cloud.google.com/apis/credentials)
   - Click **Create Credentials** > **OAuth client ID**
   - Application type: **Desktop app**
   - Name: `JBTV`
   - Click **Create**
   - Click **Download JSON**
6. Save the downloaded file as `server/google-credentials.json`
7. Make sure `config.json` has:
   ```json
   "google": {
     "calendarId": "primary",
     "credentials": "./google-credentials.json"
   }
   ```
8. The first time the server starts, it will prompt you to authorize in a browser (one time).

---

## Quick Reference

| Module | Key Needed | Free? | Link |
|--------|-----------|-------|------|
| Weather | OpenWeatherMap API key | Yes (1k calls/day) | [Sign up](https://home.openweathermap.org/users/sign_up) |
| Spotify | Client ID + Secret | Yes (requires Spotify account) | [Dashboard](https://developer.spotify.com/dashboard) |
| Calendar | Google OAuth credentials | Yes | [Cloud Console](https://console.cloud.google.com/) |
| Photos | Google OAuth credentials (same as Calendar) | Yes | Same as above |
| News | None needed | N/A | Uses RSS feeds |
| Sports | None needed | N/A | Uses ESPN public API |
| Stocks/Crypto | None needed | N/A | Uses Yahoo Finance + CoinGecko |
| Clock | None needed | N/A | Local time |
| Quotes | None needed | N/A | Built-in collection |
| Countdowns | None needed | N/A | Config-based |

---

## After Adding Keys

1. Copy your config: `cp server/config.example.json server/config.json`
2. Fill in your keys in `server/config.json`
3. Start the server: `cd server && npm run dev`
4. Check the console — it will tell you which modules are active vs disabled
