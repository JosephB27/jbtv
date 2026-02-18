// Generates 4K gradient background PNGs for JBTV
// Usage: node generate-backgrounds.js
// Requires: npm install canvas (in tools dir)

import { createCanvas, loadImage } from 'canvas';
import { writeFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const W = 3840;
const H = 2160;

const backgrounds = {
  bg_morning: {
    stops: [
      { pos: 0.0, color: '#1a0533' },
      { pos: 0.4, color: '#6b2fa0' },
      { pos: 0.7, color: '#ff6b6b' },
      { pos: 1.0, color: '#ffd93d' },
    ],
    angle: 135,
  },
  bg_afternoon: {
    stops: [
      { pos: 0.0, color: '#0c3483' },
      { pos: 0.5, color: '#4a7cf7' },
      { pos: 0.8, color: '#6b9dfc' },
      { pos: 1.0, color: '#a8d8ea' },
    ],
    angle: 180,
  },
  bg_evening: {
    stops: [
      { pos: 0.0, color: '#2d1b69' },
      { pos: 0.4, color: '#8e2de2' },
      { pos: 0.7, color: '#c850c0' },
      { pos: 1.0, color: '#ff6b35' },
    ],
    angle: 135,
  },
  bg_night: {
    stops: [
      { pos: 0.0, color: '#0a0a2e' },
      { pos: 0.5, color: '#1a1a4e' },
      { pos: 1.0, color: '#0d1b2a' },
    ],
    angle: 160,
  },
};

function degreesToCoords(angle, w, h) {
  const rad = (angle - 90) * (Math.PI / 180);
  const cx = w / 2, cy = h / 2;
  const len = Math.sqrt(w * w + h * h) / 2;
  return {
    x0: cx - Math.cos(rad) * len,
    y0: cy - Math.sin(rad) * len,
    x1: cx + Math.cos(rad) * len,
    y1: cy + Math.sin(rad) * len,
  };
}

for (const [name, config] of Object.entries(backgrounds)) {
  const canvas = createCanvas(W, H);
  const ctx = canvas.getContext('2d');

  const { x0, y0, x1, y1 } = degreesToCoords(config.angle, W, H);
  const gradient = ctx.createLinearGradient(x0, y0, x1, y1);
  for (const stop of config.stops) {
    gradient.addColorStop(stop.pos, stop.color);
  }
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, W, H);

  const outPath = resolve(__dirname, '..', 'roku', 'images', `${name}.png`);
  writeFileSync(outPath, canvas.toBuffer('image/png'));
  console.log(`Generated: ${outPath}`);
}

// Generate splash screens with user's logo centered on gradient background
const logoPath = resolve(__dirname, '..', 'roku', 'images', 'channel_logo_hd.png');
const logo = await loadImage(logoPath);

for (const [name, size] of [['splash_fhd.png', [1920, 1080]], ['splash_hd.png', [1280, 720]]]) {
  const [sw, sh] = size;
  const canvas = createCanvas(sw, sh);
  const ctx = canvas.getContext('2d');
  const gradient = ctx.createLinearGradient(0, 0, sw, sh);
  gradient.addColorStop(0, '#0a0a2e');
  gradient.addColorStop(1, '#1a1a4e');
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, sw, sh);

  // Scale logo to fit nicely (40% of screen height)
  const scale = (sh * 0.4) / logo.height;
  const lw = logo.width * scale;
  const lh = logo.height * scale;
  ctx.drawImage(logo, (sw - lw) / 2, (sh - lh) / 2, lw, lh);

  const outPath = resolve(__dirname, '..', 'roku', 'images', name);
  writeFileSync(outPath, canvas.toBuffer('image/png'));
  console.log(`Generated: ${outPath}`);
}

console.log('\nAll assets generated!');
