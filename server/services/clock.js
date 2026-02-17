import config from '../utils/config.js';

export function getClock() {
  const now = new Date();
  const hour = now.getHours();

  let period, greeting;
  if (hour >= 5 && hour < 12) {
    period = 'morning';
    greeting = `Good morning, ${config.user.name}`;
  } else if (hour >= 12 && hour < 17) {
    period = 'afternoon';
    greeting = `Good afternoon, ${config.user.name}`;
  } else if (hour >= 17 && hour < 21) {
    period = 'evening';
    greeting = `Good evening, ${config.user.name}`;
  } else {
    period = 'night';
    greeting = `Good night, ${config.user.name}`;
  }

  return {
    greeting,
    period,
    time: now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }),
    date: now.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }),
  };
}
