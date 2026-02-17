// Generates 4K gradient background PNGs for JBTV
// Usage: node generate-backgrounds.js
// Requires: npm install canvas (in tools dir)

import { createCanvas } from 'canvas';
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

// Also generate splash screen
const canvas = createCanvas(1920, 1080);
const ctx = canvas.getContext('2d');
const gradient = ctx.createLinearGradient(0, 0, 1920, 1080);
gradient.addColorStop(0, '#0a0a2e');
gradient.addColorStop(1, '#1a1a4e');
ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 1920, 1080);

ctx.fillStyle = '#00D4AA';
ctx.font = 'bold 120px sans-serif';
ctx.textAlign = 'center';
ctx.textBaseline = 'middle';
ctx.fillText('JBTV', 960, 540);

const splashPath = resolve(__dirname, '..', 'roku', 'images', 'splash_fhd.png');
writeFileSync(splashPath, canvas.toBuffer('image/png'));
console.log(`Generated: ${splashPath}`);

// HD splash
const canvas2 = createCanvas(1920, 1080);
const ctx2 = canvas2.getContext('2d');
const g2 = ctx2.createLinearGradient(0, 0, 1920, 1080);
g2.addColorStop(0, '#0a0a2e');
g2.addColorStop(1, '#1a1a4e');
ctx2.fillStyle = g2;
ctx2.fillRect(0, 0, 1920, 1080);
ctx2.fillStyle = '#00D4AA';
ctx2.font = 'bold 120px sans-serif';
ctx2.textAlign = 'center';
ctx2.textBaseline = 'middle';
ctx2.fillText('JBTV', 960, 540);
const splashHdPath = resolve(__dirname, '..', 'roku', 'images', 'splash_hd.png');
writeFileSync(splashHdPath, canvas2.toBuffer('image/png'));
console.log(`Generated: ${splashHdPath}`);

// Channel logos
const logoHd = createCanvas(540, 405);
const lctx = logoHd.getContext('2d');
const lg = lctx.createLinearGradient(0, 0, 540, 405);
lg.addColorStop(0, '#0a0a2e');
lg.addColorStop(1, '#1a1a4e');
lctx.fillStyle = lg;
lctx.fillRect(0, 0, 540, 405);
lctx.fillStyle = '#00D4AA';
lctx.font = 'bold 80px sans-serif';
lctx.textAlign = 'center';
lctx.textBaseline = 'middle';
lctx.fillText('JBTV', 270, 202);
writeFileSync(resolve(__dirname, '..', 'roku', 'images', 'channel_logo_hd.png'), logoHd.toBuffer('image/png'));

const logoSd = createCanvas(214, 144);
const lctx2 = logoSd.getContext('2d');
const lg2 = lctx2.createLinearGradient(0, 0, 214, 144);
lg2.addColorStop(0, '#0a0a2e');
lg2.addColorStop(1, '#1a1a4e');
lctx2.fillStyle = lg2;
lctx2.fillRect(0, 0, 214, 144);
lctx2.fillStyle = '#00D4AA';
lctx2.font = 'bold 36px sans-serif';
lctx2.textAlign = 'center';
lctx2.textBaseline = 'middle';
lctx2.fillText('JBTV', 107, 72);
writeFileSync(resolve(__dirname, '..', 'roku', 'images', 'channel_logo_sd.png'), logoSd.toBuffer('image/png'));

console.log('\nAll assets generated!');
