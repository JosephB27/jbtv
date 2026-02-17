import express from 'express';
import config from './utils/config.js';
import dashboardRouter from './routes/dashboard.js';

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

app.use('/api', dashboardRouter);

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`JBTV server running at http://0.0.0.0:${port}`);
  console.log(`Dashboard: http://localhost:${port}/api/dashboard`);
  console.log(`Health:    http://localhost:${port}/health`);
});
