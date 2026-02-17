# JBTV - Personal Morning Dashboard for Roku TV

## Project Overview

JBTV is a personalized morning dashboard that runs as a sideloaded Roku channel. It displays weather, calendar events, countdowns, news, motivational quotes, Spotify info, sports scores, stock/crypto tickers, and personal photos on a beautiful glassmorphism-style interface. The system has two parts: a Roku channel (frontend) and a Node.js backend server running on a local laptop.

## Architecture

```
┌─────────────────┐         HTTP/JSON          ┌─────────────────────┐
│   Roku Channel   │  ◄──────────────────────►  │   Backend Server     │
│  (BrightScript/  │     Local Network          │   (Node.js)          │
│   SceneGraph)    │                            │   Old Laptop 24/7    │
└─────────────────┘                             └────────┬────────────┘
                                                         │
                                         ┌───────────────┼───────────────┐
                                         │               │               │
                                    Weather API    Google Calendar   Spotify API
                                   (OpenWeather)     (OAuth2)        (OAuth2)
                                         │               │               │
                                    News RSS        Quotes DB       Config/
                                    Feeds           (local)         Countdowns
                                         │               │               │
                                    Sports API    Stock/Crypto    Google Photos
                                   (ESPN/API)     (Yahoo/Coin)      (OAuth2)
```

### Roku Channel (`/roku`)
- **Language:** BrightScript + SceneGraph XML
- **Purpose:** Renders the dashboard UI on the TV
- **Behavior:** Polls the backend server every 30-60 seconds for fresh data
- **Navigation:** Roku remote for switching between module panels

### Backend Server (`/server`)
- **Runtime:** Node.js (ES modules, modern JS)
- **Framework:** Express.js
- **Purpose:** Aggregates all external APIs into a single unified JSON endpoint
- **Hosting:** Runs 24/7 on an old laptop on the local network
- **Port:** 8888

## Modules (v1)

### 1. Clock & Greeting
- Large digital clock with date
- Personalized greeting: "Good morning/afternoon/evening, Joseph"
- Dynamic based on time of day

### 2. Weather
- **API:** OpenWeatherMap (free tier)
- Current conditions: temp, feels-like, icon, description
- 5-day forecast summary
- Sunrise/sunset times
- Location: configurable in server config

### 3. Calendar
- **API:** Google Calendar API (OAuth2)
- Today's events with times
- "Next up" indicator with time-until
- Shows up to 8 events for the day

### 4. Countdowns
- Days remaining until important dates
- Configured in a local JSON file on the server
- Examples: trips, birthdays, goals, releases
- Visual progress indicator

### 5. Motivational Quotes
- Rotating daily quote
- Source: local curated JSON file of quotes (with option to add API later)
- Shows quote + author

### 6. News Headlines
- **Source:** RSS feeds (configurable list of sources)
- Top 5 headlines with source attribution
- Rotates/cycles through headlines

### 7. Spotify
- **API:** Spotify Web API (OAuth2)
- Currently playing track (if active)
- Recently played tracks
- Album art display
- Playback controls are NOT in scope (display only)

### 8. Sports Scores
- **API:** ESPN API (free, unofficial) or API-Sports
- Last game scores for your configured teams
- Next upcoming game with date/time
- Team logos
- Supports NFL, NBA, MLB, NHL, soccer — configurable per team
- Configured in `config.json` with team IDs

### 9. Stock & Crypto Tickers
- **API:** Yahoo Finance (via yahoo-finance2 npm) for stocks, CoinGecko (free tier) for crypto
- Scrolling ticker or small card display
- Shows symbol, current price, daily change (% and color-coded green/red)
- Configurable list of tickers in `config.json`
- Updates every 5 minutes (respects rate limits)

### 10. Google Photos
- **API:** Google Photos Library API (OAuth2, same Google account as Calendar)
- Cycles through photos from a configured album
- Can be used as dashboard background or as a dedicated photo card
- Rotates every 30-60 seconds
- Server fetches photo URLs and caches them; Roku loads images directly

## Visual Design

### Style: Glassmorphism
- **Background:** Dynamic gradient that shifts with time of day
  - Morning (5am-11am): Warm sunrise gradient (deep purple → coral → golden)
  - Afternoon (11am-5pm): Bright sky gradient (blue → cyan)
  - Evening (5pm-9pm): Sunset gradient (orange → magenta → purple)
  - Night (9pm-5am): Deep dark gradient (navy → deep purple)
- **Cards:** Semi-transparent rectangles (white at 10-15% opacity) with subtle borders
- **Text:** Clean sans-serif, white primary text, light gray secondary
- **Accent color:** Soft cyan/teal (#00D4AA) for highlights and active states
- **Layout:** Grid of cards, balanced spacing, no clutter

### SceneGraph Implementation Notes
- Use `Rectangle` nodes with `opacity` for glass card effect
- Use `Poster` nodes for weather icons, album art, etc.
- Use `Label` and `ScrollingLabel` for text
- Use `LayoutGroup` and `Group` for card arrangements
- Background gradient via a pre-rendered poster image set (one per time period)
- Approximate blur via layered semi-transparent rectangles
- Target resolution: 3840x2160 (4K UHD)

## Project Structure

```
jbtv/
├── CLAUDE.md
├── roku/                          # Roku channel
│   ├── manifest                   # Channel manifest
│   ├── source/
│   │   └── main.brs              # Entry point
│   ├── components/
│   │   ├── MainScene.xml         # Root scene
│   │   ├── MainScene.brs         # Scene logic
│   │   ├── cards/
│   │   │   ├── WeatherCard.xml
│   │   │   ├── WeatherCard.brs
│   │   │   ├── CalendarCard.xml
│   │   │   ├── CalendarCard.brs
│   │   │   ├── CountdownCard.xml
│   │   │   ├── CountdownCard.brs
│   │   │   ├── QuoteCard.xml
│   │   │   ├── QuoteCard.brs
│   │   │   ├── NewsCard.xml
│   │   │   ├── NewsCard.brs
│   │   │   ├── SpotifyCard.xml
│   │   │   ├── SpotifyCard.brs
│   │   │   ├── ClockCard.xml
│   │   │   ├── ClockCard.brs
│   │   │   ├── SportsCard.xml
│   │   │   ├── SportsCard.brs
│   │   │   ├── TickerCard.xml
│   │   │   ├── TickerCard.brs
│   │   │   ├── PhotoCard.xml
│   │   │   └── PhotoCard.brs
│   │   └── shared/
│   │       ├── GlassCard.xml     # Reusable glass card component
│   │       └── GlassCard.brs
│   └── images/
│       ├── bg_morning.png        # Pre-rendered gradient backgrounds
│       ├── bg_afternoon.png
│       ├── bg_evening.png
│       ├── bg_night.png
│       ├── channel_logo_hd.png   # Channel icon
│       ├── channel_logo_sd.png
│       └── splash_hd.png         # Loading splash
├── server/
│   ├── package.json
│   ├── index.js                  # Express server entry
│   ├── config.json               # User config (location, feeds, countdowns)
│   ├── quotes.json               # Curated quotes database
│   ├── routes/
│   │   └── dashboard.js          # GET /api/dashboard — unified data endpoint
│   ├── services/
│   │   ├── weather.js            # OpenWeatherMap integration
│   │   ├── calendar.js           # Google Calendar integration
│   │   ├── countdowns.js         # Countdown calculator
│   │   ├── quotes.js             # Quote of the day
│   │   ├── news.js               # RSS feed aggregator
│   │   ├── spotify.js            # Spotify API integration
│   │   ├── sports.js             # ESPN/sports API integration
│   │   ├── stocks.js             # Yahoo Finance + CoinGecko integration
│   │   └── photos.js             # Google Photos API integration
│   └── utils/
│       └── cache.js              # Simple in-memory cache with TTL
└── tools/
    ├── package.sh                # Script to package roku/ into .zip for sideloading
    └── deploy.sh                 # Script to sideload onto Roku via curl
```

## API Design

### `GET /api/dashboard`

Returns all module data in one response. The Roku channel makes a single call to get everything.

```json
{
  "clock": {
    "greeting": "Good morning, Joseph",
    "period": "morning"
  },
  "weather": {
    "current": {
      "temp": 72,
      "feelsLike": 68,
      "description": "Partly cloudy",
      "icon": "02d",
      "humidity": 45
    },
    "forecast": [...],
    "sunrise": "6:42 AM",
    "sunset": "7:18 PM"
  },
  "calendar": {
    "events": [
      { "title": "Team Standup", "time": "9:00 AM", "duration": "30m", "isNext": true }
    ]
  },
  "countdowns": [
    { "label": "Trip to Japan", "daysLeft": 42, "date": "2026-04-01" }
  ],
  "quote": {
    "text": "The obstacle is the way.",
    "author": "Marcus Aurelius"
  },
  "news": [
    { "title": "Headline here", "source": "AP News", "url": "..." }
  ],
  "spotify": {
    "nowPlaying": null,
    "recentTracks": [
      { "name": "Track Name", "artist": "Artist", "albumArt": "https://..." }
    ]
  },
  "sports": [
    {
      "team": "Lakers",
      "league": "NBA",
      "logo": "https://...",
      "lastGame": { "opponent": "Celtics", "score": "112-108", "result": "W" },
      "nextGame": { "opponent": "Warriors", "date": "Feb 20", "time": "7:30 PM" }
    }
  ],
  "tickers": [
    { "symbol": "AAPL", "price": 234.56, "change": +1.23, "changePercent": +0.53 },
    { "symbol": "BTC", "price": 98432, "change": -1205, "changePercent": -1.21 }
  ],
  "photos": {
    "current": "https://lh3.googleusercontent.com/...",
    "albumName": "Favorites"
  }
}
```

## Roku Sideloading

1. Enable Developer Mode on Roku: Home 3x, Up 2x, Right, Left, Right, Left, Right
2. Note the Roku's IP address from Settings > Network
3. Package channel: `cd tools && bash package.sh`
4. Deploy: `bash deploy.sh <ROKU_IP> <DEV_PASSWORD>`
   - Uses curl to POST the .zip to `http://<ROKU_IP>/plugin_install`

## Development Workflow

1. **Backend first:** Get the server running with mock/real data
2. **Roku second:** Build the channel UI, pointing at the backend
3. **Iterate:** Refine the look and feel card by card

### Running the backend
```bash
cd server && npm install && node index.js
```

### Packaging the Roku channel
```bash
cd tools && bash package.sh   # creates jbtv.zip
bash deploy.sh 192.168.x.x password  # sideloads to Roku
```

## Config (`server/config.json`)

```json
{
  "user": {
    "name": "Joseph"
  },
  "weather": {
    "apiKey": "YOUR_OPENWEATHERMAP_KEY",
    "lat": 0.0,
    "lon": 0.0,
    "units": "imperial"
  },
  "google": {
    "calendarId": "primary",
    "credentials": "./google-credentials.json"
  },
  "spotify": {
    "clientId": "YOUR_SPOTIFY_CLIENT_ID",
    "clientSecret": "YOUR_SPOTIFY_CLIENT_SECRET"
  },
  "news": {
    "feeds": [
      "https://feeds.apnews.com/rss/topnews",
      "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
    ],
    "maxItems": 5
  },
  "countdowns": [
    { "label": "Trip to Japan", "date": "2026-04-01" },
    { "label": "Mom's Birthday", "date": "2026-06-15" }
  ],
  "sports": {
    "teams": [
      { "league": "nba", "team": "lakers" },
      { "league": "nfl", "team": "rams" }
    ]
  },
  "tickers": {
    "stocks": ["AAPL", "TSLA", "NVDA"],
    "crypto": ["bitcoin", "ethereum"]
  },
  "photos": {
    "albumName": "Favorites",
    "rotateIntervalSeconds": 45
  },
  "server": {
    "port": 8888,
    "backendUrl": "http://LOCAL_LAPTOP_IP:8888"
  }
}
```

## Task Tracking with Beads (`bd`)

This project uses [beads](https://github.com/steveyegge/beads) (`bd`) for task/issue tracking. Beads is a distributed, git-backed graph issue tracker designed for AI coding agents. It provides persistent, structured memory with dependency-aware task graphs.

### Key Commands

| Command | Action |
|---------|--------|
| `bd ready` | List tasks with no open blockers (what to work on next) |
| `bd create "Title" -p <priority>` | Create a task (P0=critical, P1=high, P2=normal, P3=low) |
| `bd update <id> --claim` | Claim a task (sets assignee + in_progress) |
| `bd update <id> --status done` | Mark task complete |
| `bd dep add <child> <parent>` | Add dependency (child blocked by parent) |
| `bd show <id>` | View task details |
| `bd list` | List all tasks |
| `bd sync` | Sync database with git (export JSONL, commit) |

### Workflow Rules

- **Before starting work:** Run `bd ready` to find unblocked tasks
- **When starting a task:** Run `bd update <id> --claim` to claim it
- **When done:** Run `bd update <id> --status done`
- **After making changes:** Run `bd sync` to persist
- **Commit messages:** Include issue ID, e.g. `"Add weather service (jbtv-abc)"`
- **DO NOT use `bd edit`** — it opens an interactive editor. Use `bd update` with flags instead.
- Issue prefix: `jbtv` (issues named `jbtv-<hash>`)

## Key Constraints & Notes

- **BrightScript is quirky:** No classes, limited data structures, 1-indexed arrays, case-insensitive. Use associative arrays (like JS objects) heavily.
- **SceneGraph is XML-based:** UI components are defined in XML, logic in companion .brs files. Rendering is node-based (similar to a scene tree).
- **No web views on Roku:** Everything must be native SceneGraph — no HTML/CSS/JS on the Roku side.
- **Network requests:** Use `roUrlTransfer` for HTTP calls from BrightScript. Always run in a Task node (background thread) to avoid freezing the UI.
- **Image caching:** Roku caches images from URLs automatically. Leverage this for album art, weather icons.
- **OAuth tokens:** Google and Spotify OAuth flows happen on the server (device/web flow), tokens stored server-side. The Roku never handles OAuth directly.
- **Sensitive files:** Never commit `config.json`, `google-credentials.json`, or any file with API keys/secrets. Use a `.gitignore`.

## Tech Stack Summary

| Component | Technology |
|-----------|-----------|
| TV Frontend | BrightScript + SceneGraph (Roku) |
| Backend Server | Node.js + Express |
| Weather | OpenWeatherMap API |
| Calendar | Google Calendar API |
| Music | Spotify Web API |
| News | RSS (rss-parser npm) |
| Quotes | Local JSON file |
| Sports | ESPN API (unofficial) |
| Stocks | Yahoo Finance (yahoo-finance2 npm) |
| Crypto | CoinGecko API (free tier) |
| Photos | Google Photos Library API |
| Task Tracking | Beads (`bd`) — git-backed issue tracker |
| Deployment | Roku sideloading via HTTP |
