import config from '../utils/config.js';

export function getCountdowns() {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  return (config.countdowns || [])
    .map(({ label, date }) => {
      const target = new Date(date + 'T00:00:00');
      const diffMs = target - today;
      const daysLeft = Math.round(diffMs / (1000 * 60 * 60 * 24));

      return {
        label,
        date,
        daysLeft: Math.abs(daysLeft),
        isPast: daysLeft < 0,
      };
    })
    .sort((a, b) => {
      if (a.isPast !== b.isPast) return a.isPast ? 1 : -1;
      return a.daysLeft - b.daysLeft;
    });
}
