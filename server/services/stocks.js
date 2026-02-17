import YahooFinance from 'yahoo-finance2';
import config from '../utils/config.js';
import cache from '../utils/cache.js';

const TTL = 5 * 60 * 1000; // 5 minutes
const COINGECKO = 'https://api.coingecko.com/api/v3';

const yf = new YahooFinance({ queue: { concurrency: 1, intervalCap: 1, interval: 2000 } });

async function fetchStocks() {
  const symbols = config.tickers?.stocks || [];
  if (symbols.length === 0) return [];

  const results = [];
  for (const sym of symbols) {
    try {
      const q = await yf.quote(sym);
      if (q) {
        results.push({
          symbol: q.symbol,
          price: q.regularMarketPrice,
          change: parseFloat((q.regularMarketChange || 0).toFixed(2)),
          changePercent: parseFloat((q.regularMarketChangePercent || 0).toFixed(2)),
          name: q.shortName || q.longName || sym,
          type: 'stock',
        });
      }
    } catch (err) {
      console.warn(`Stock fetch failed for ${sym}:`, err.message?.slice(0, 80));
      // Fallback: try Alpha Vantage-style free API
      try {
        const res = await fetch(`https://query1.finance.yahoo.com/v8/finance/chart/${sym}?interval=1d&range=1d`);
        if (res.ok) {
          const data = await res.json();
          const meta = data.chart?.result?.[0]?.meta;
          if (meta) {
            const price = meta.regularMarketPrice;
            const prevClose = meta.chartPreviousClose || meta.previousClose;
            const change = prevClose ? price - prevClose : 0;
            const pct = prevClose ? (change / prevClose) * 100 : 0;
            results.push({
              symbol: sym,
              price,
              change: parseFloat(change.toFixed(2)),
              changePercent: parseFloat(pct.toFixed(2)),
              name: meta.shortName || sym,
              type: 'stock',
            });
          }
        }
      } catch {
        // Skip this ticker entirely
      }
    }
  }

  return results;
}

async function fetchCrypto() {
  const ids = config.tickers?.crypto || [];
  if (ids.length === 0) return [];

  const symbolMap = {
    bitcoin: 'BTC', ethereum: 'ETH', solana: 'SOL', dogecoin: 'DOGE',
    cardano: 'ADA', ripple: 'XRP', polkadot: 'DOT', avalanche: 'AVAX',
    chainlink: 'LINK', litecoin: 'LTC',
  };

  const res = await fetch(
    `${COINGECKO}/simple/price?ids=${ids.join(',')}&vs_currencies=usd&include_24hr_change=true&include_24hr_vol=true`
  );
  if (!res.ok) return [];

  const data = await res.json();
  return ids
    .filter(id => data[id])
    .map(id => ({
      symbol: symbolMap[id] || id.toUpperCase().slice(0, 5),
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

  if (result.length > 0) {
    cache.set('tickers', result, TTL);
  }
  return result;
}
