import { google } from 'googleapis';
import { getAuthClient } from '../utils/google-auth.js';
import config from '../utils/config.js';
import cache from '../utils/cache.js';

const TTL = 2 * 60 * 1000; // 2 minutes

export async function getCalendar() {
  const cached = cache.get('calendar');
  if (cached) return cached;

  const auth = await getAuthClient();
  if (!auth) return { events: [] };

  const cal = google.calendar({ version: 'v3', auth });

  const now = new Date();
  const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);

  const res = await cal.events.list({
    calendarId: config.google?.calendarId || 'primary',
    timeMin: startOfDay.toISOString(),
    timeMax: endOfDay.toISOString(),
    singleEvents: true,
    orderBy: 'startTime',
    maxResults: 8,
  });

  const events = (res.data.items || []).map(event => {
    const isAllDay = !!event.start.date;
    const start = isAllDay ? null : new Date(event.start.dateTime);
    const end = isAllDay ? null : new Date(event.end.dateTime);

    let duration = null;
    let minutesUntil = null;
    if (start && end) {
      const mins = Math.round((end - start) / 60000);
      duration = mins >= 60 ? `${Math.floor(mins / 60)}h${mins % 60 ? ` ${mins % 60}m` : ''}` : `${mins}m`;
      minutesUntil = Math.round((start - now) / 60000);
    }

    return {
      title: event.summary || '(No title)',
      time: isAllDay ? 'All day' : start.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }),
      endTime: isAllDay ? null : end.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }),
      duration,
      location: event.location || null,
      isAllDay,
      isNext: false,
      minutesUntil,
    };
  });

  // Mark the next upcoming event
  const upcoming = events.find(e => e.minutesUntil !== null && e.minutesUntil > 0);
  if (upcoming) upcoming.isNext = true;

  const result = { events };
  cache.set('calendar', result, TTL);
  return result;
}
