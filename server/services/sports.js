import config from '../utils/config.js';
import cache from '../utils/cache.js';

const TTL = 5 * 60 * 1000; // 5 minutes
const ESPN = 'https://site.api.espn.com/apis/site/v2/sports';

const LEAGUE_MAP = {
  nba: 'basketball/nba',
  nfl: 'football/nfl',
  mlb: 'baseball/mlb',
  nhl: 'hockey/nhl',
  mls: 'soccer/usa.1',
  epl: 'soccer/eng.1',
  laliga: 'soccer/esp.1',
};

async function fetchTeam(league, teamSlug) {
  const path = LEAGUE_MAP[league];
  if (!path) return null;

  const cacheKey = `sports:${league}:${teamSlug}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  // Get team info by searching the scoreboard
  const scoreRes = await fetch(`${ESPN}/${path}/scoreboard`);
  if (!scoreRes.ok) return null;
  const scoreData = await scoreRes.json();

  // Also fetch team schedule for next game
  const teamsRes = await fetch(`${ESPN}/${path}/teams?limit=100`);
  if (!teamsRes.ok) return null;
  const teamsData = await teamsRes.json();

  // Find team
  const team = (teamsData.sports?.[0]?.leagues?.[0]?.teams || [])
    .map(t => t.team)
    .find(t =>
      t.slug === teamSlug ||
      t.abbreviation.toLowerCase() === teamSlug.toLowerCase() ||
      t.displayName.toLowerCase().includes(teamSlug.toLowerCase())
    );

  if (!team) {
    console.warn(`Sports: team "${teamSlug}" not found in ${league}`);
    return null;
  }

  // Fetch team schedule
  const schedRes = await fetch(`${ESPN}/${path}/teams/${team.id}/schedule`);
  let lastGame = null;
  let nextGame = null;

  if (schedRes.ok) {
    const schedData = await schedRes.json();
    const events = schedData.events || [];
    const now = Date.now();

    for (const event of events) {
      const eventDate = new Date(event.date).getTime();
      const competition = event.competitions?.[0];
      if (!competition) continue;

      const competitors = competition.competitors || [];
      const us = competitors.find(c => c.id === String(team.id));
      const them = competitors.find(c => c.id !== String(team.id));
      if (!us || !them) continue;

      if (competition.status?.type?.completed) {
        const ourScore = parseInt(us.score?.displayValue || us.score || '0');
        const theirScore = parseInt(them.score?.displayValue || them.score || '0');
        lastGame = {
          opponent: them.team?.displayName || 'TBD',
          score: `${ourScore}-${theirScore}`,
          result: ourScore > theirScore ? 'W' : ourScore < theirScore ? 'L' : 'T',
          date: new Date(event.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        };
      } else if (eventDate > now && !nextGame) {
        nextGame = {
          opponent: them.team?.displayName || 'TBD',
          date: new Date(event.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
          time: new Date(event.date).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }),
          broadcast: competition.broadcasts?.[0]?.names?.[0] || null,
        };
      }
    }
  }

  const result = {
    team: team.displayName,
    league: league.toUpperCase(),
    logo: team.logos?.[0]?.href || null,
    lastGame,
    nextGame,
  };

  cache.set(cacheKey, result, TTL);
  return result;
}

export async function getSports() {
  const teams = config.sports?.teams || [];
  if (teams.length === 0) return [];

  const results = await Promise.allSettled(
    teams.map(({ league, team }) => fetchTeam(league, team))
  );

  return results
    .filter(r => r.status === 'fulfilled' && r.value)
    .map(r => r.value);
}
