import express from 'express';
import config from './utils/config.js';
import dashboardRouter from './routes/dashboard.js';
import { networkInterfaces } from 'os';

const app = express();
const port = config.server.port;

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

app.get('/api/discover', (req, res) => {
  res.json({ service: 'jbtv', version: '1.0.0', name: config.user.name });
});

app.use('/api', dashboardRouter);

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

function getLocalIp() {
  const nets = networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) return net.address;
    }
  }
  return '127.0.0.1';
}

app.listen(port, '0.0.0.0', () => {
  const ip = getLocalIp();
  console.log(`\nJBTV server running at http://${ip}:${port}`);
  console.log(`Dashboard: http://${ip}:${port}/api/dashboard`);
  console.log(`Health:    http://${ip}:${port}/health\n`);
});
