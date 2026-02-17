import { Router } from 'express';
import { getClock } from '../services/clock.js';
import { getWeather } from '../services/weather.js';
import { getCalendar } from '../services/calendar.js';
import { getCountdowns } from '../services/countdowns.js';
import { getQuote } from '../services/quotes.js';
import { getNews } from '../services/news.js';
import { getSpotify } from '../services/spotify.js';
import { getSports } from '../services/sports.js';
import { getTickers } from '../services/stocks.js';
import { getPhotos } from '../services/photos.js';

const router = Router();

router.get('/dashboard', async (req, res) => {
  const services = {
    weather: getWeather(),
    calendar: getCalendar(),
    news: getNews(),
    spotify: getSpotify(),
    sports: getSports(),
    tickers: getTickers(),
    photos: getPhotos(),
  };

  const results = await Promise.allSettled(Object.values(services));
  const keys = Object.keys(services);
  const data = {};

  const failed = [];
  keys.forEach((key, i) => {
    if (results[i].status === 'fulfilled') {
      data[key] = results[i].value;
    } else {
      data[key] = null;
      failed.push(key);
      console.error(`Service "${key}" failed:`, results[i].reason?.message || results[i].reason);
    }
  });

  // Sync services (never fail)
  data.clock = getClock();
  data.countdowns = getCountdowns();
  data.quote = getQuote();
  data.fetchedAt = new Date().toISOString();

  if (failed.length > 0) {
    console.warn(`Dashboard served with ${failed.length} failed service(s): ${failed.join(', ')}`);
  }

  res.json(data);
});

export default router;
