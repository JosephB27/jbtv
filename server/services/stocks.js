import yahooFinance from 'yahoo-finance2';
import config from '../utils/config.js';
import cache from '../utils/cache.js';

const TTL = 5 * 60 * 1000; // 5 minutes
const COINGECKO = 'https://api.coingecko.com/api/v3';

async function fetchStocks() {
  const symbols = config.tickers?.stocks || [];
  if (symbols.length === 0) return [];

  const results = await Promise.allSettled(
    symbols.map(sym => yahooFinance.quote(sym))
  );

  return results
    .filter(r => r.status === 'fulfilled' && r.value)
    .map(r => {
      const q = r.value;
      return {
        symbol: q.symbol,
        price: q.regularMarketPrice,
        change: parseFloat((q.regularMarketChange || 0).toFixed(2)),
        changePercent: parseFloat((q.regularMarketChangePercent || 0).toFixed(2)),
        type: 'stock',
      };
    });
}

async function fetchCrypto() {
  const ids = config.tickers?.crypto || [];
  if (ids.length === 0) return [];

  const res = await fetch(
    `${COINGECKO}/simple/price?ids=${ids.join(',')}&vs_currencies=usd&include_24hr_change=true`
  );
  if (!res.ok) return [];

  const data = await res.json();
  return ids
    .filter(id => data[id])
    .map(id => ({
      symbol: id === 'bitcoin' ? 'BTC' : id === 'ethereum' ? 'ETH' : id.toUpperCase().slice(0, 5),
      price: data[id].usd,
      change: null,
      changePercent: parseFloat((data[id].usd_24h_change || 0).toFixed(2)),
      type: 'crypto',
    }));
}

export async function getTickers() {
  const cached = cache.get('tickers');
  if (cached) return cached;

  const [stocks, crypto] = await Promise.allSettled([fetchStocks(), fetchCrypto()]);

  const result = [
    ...(stocks.status === 'fulfilled' ? stocks.value : []),
    ...(crypto.status === 'fulfilled' ? crypto.value : []),
  ];

  cache.set('tickers', result, TTL);
  return result;
}
