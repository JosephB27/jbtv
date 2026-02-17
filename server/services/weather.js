import config from '../utils/config.js';
import cache from '../utils/cache.js';

const TTL = 10 * 60 * 1000; // 10 minutes
const BASE = 'https://api.openweathermap.org/data/2.5';

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Weather API ${res.status}: ${res.statusText}`);
  return res.json();
}

function formatTime(unix, tz) {
  return new Date((unix + tz) * 1000).toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
    timeZone: 'UTC',
  });
}

export async function getWeather() {
  const { apiKey, lat, lon, units } = config.weather;
  if (!apiKey || String(apiKey).startsWith('YOUR_')) return null;

  const cached = cache.get('weather');
  if (cached) return cached;
  const params = `lat=${lat}&lon=${lon}&units=${units}&appid=${apiKey}`;

  const [current, forecast] = await Promise.all([
    fetchJson(`${BASE}/weather?${params}`),
    fetchJson(`${BASE}/forecast?${params}`),
  ]);

  const result = {
    current: {
      temp: Math.round(current.main.temp),
      feelsLike: Math.round(current.main.feels_like),
      description: current.weather[0].description,
      icon: current.weather[0].icon,
      humidity: current.main.humidity,
      wind: Math.round(current.wind.speed),
    },
    forecast: parseForecast(forecast.list, units),
    sunrise: formatTime(current.sys.sunrise, current.timezone),
    sunset: formatTime(current.sys.sunset, current.timezone),
  };

  cache.set('weather', result, TTL);
  return result;
}

function parseForecast(list, units) {
  // Group by day, take noon reading for each
  const days = {};
  for (const item of list) {
    const date = item.dt_txt.split(' ')[0];
    const hour = parseInt(item.dt_txt.split(' ')[1].split(':')[0]);
    if (!days[date] || Math.abs(hour - 12) < Math.abs(days[date].hour - 12)) {
      days[date] = {
        hour,
        date,
        dayName: new Date(date + 'T12:00:00').toLocaleDateString('en-US', { weekday: 'short' }),
        high: Math.round(item.main.temp_max),
        low: Math.round(item.main.temp_min),
        icon: item.weather[0].icon,
        description: item.weather[0].description,
      };
    }
  }

  // Skip today, return next 5
  const today = new Date().toISOString().split('T')[0];
  return Object.values(days)
    .filter(d => d.date !== today)
    .slice(0, 5)
    .map(({ hour, ...rest }) => rest);
}
