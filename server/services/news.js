import Parser from 'rss-parser';
import config from '../utils/config.js';
import cache from '../utils/cache.js';

const TTL = 15 * 60 * 1000; // 15 minutes
const parser = new Parser({ timeout: 10000 });

function timeAgo(date) {
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 60) return 'just now';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

function stripHtml(str) {
  return (str || '').replace(/<[^>]*>/g, '').replace(/&[^;]+;/g, ' ').trim();
}

export async function getNews() {
  const cached = cache.get('news');
  if (cached) return cached;

  const feeds = config.news?.feeds || [];
  if (feeds.length === 0) return [];

  const results = await Promise.allSettled(
    feeds.map(url => parser.parseURL(url))
  );

  const items = [];
  for (const result of results) {
    if (result.status !== 'fulfilled') continue;
    const feed = result.value;
    const source = feed.title || new URL(feed.feedUrl || '').hostname;
    for (const item of feed.items || []) {
      items.push({
        title: stripHtml(item.title),
        source,
        url: item.link || '',
        publishedAt: item.pubDate ? timeAgo(new Date(item.pubDate)) : null,
        _date: item.pubDate ? new Date(item.pubDate).getTime() : 0,
      });
    }
  }

  // Sort newest first, deduplicate similar titles, cap
  items.sort((a, b) => b._date - a._date);
  const seen = new Set();
  const deduped = items.filter(item => {
    const key = item.title.toLowerCase().slice(0, 50);
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  const result = deduped.slice(0, config.news?.maxItems || 5).map(({ _date, ...rest }) => rest);
  cache.set('news', result, TTL);
  return result;
}
