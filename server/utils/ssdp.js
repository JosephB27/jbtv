import { createSocket } from 'dgram';
import { networkInterfaces } from 'os';

const SSDP_ADDRESS = '239.255.255.250';
const SSDP_PORT = 1900;
const SEARCH_TARGET = 'urn:jbtv:service:dashboard:1';

function getLocalIp() {
  const nets = networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return '127.0.0.1';
}

export function startSsdpServer(port) {
  const localIp = getLocalIp();
  const location = `http://${localIp}:${port}`;
  const usn = `uuid:jbtv-dashboard-${localIp.replace(/\./g, '-')}`;

  const socket = createSocket({ type: 'udp4', reuseAddr: true });

  socket.on('message', (msg, rinfo) => {
    const message = msg.toString();
    if (!message.includes('M-SEARCH')) return;
    if (!message.includes(SEARCH_TARGET) && !message.includes('ssdp:all')) return;

    const response = [
      'HTTP/1.1 200 OK',
      `LOCATION: ${location}`,
      `ST: ${SEARCH_TARGET}`,
      `USN: ${usn}`,
      `SERVER: JBTV/1.0`,
      `CACHE-CONTROL: max-age=1800`,
      '',
      '',
    ].join('\r\n');

    socket.send(response, rinfo.port, rinfo.address);
  });

  socket.bind(SSDP_PORT, () => {
    socket.addMembership(SSDP_ADDRESS);
    console.log(`SSDP discovery active — Roku can find JBTV at ${location}`);
  });

  socket.on('error', (err) => {
    // SSDP is optional — don't crash if port is in use
    console.warn('SSDP discovery unavailable:', err.message);
  });

  // Also send periodic NOTIFY advertisements
  const notify = () => {
    const message = [
      'NOTIFY * HTTP/1.1',
      `HOST: ${SSDP_ADDRESS}:${SSDP_PORT}`,
      `LOCATION: ${location}`,
      `NT: ${SEARCH_TARGET}`,
      `NTS: ssdp:alive`,
      `USN: ${usn}`,
      `SERVER: JBTV/1.0`,
      `CACHE-CONTROL: max-age=1800`,
      '',
      '',
    ].join('\r\n');

    socket.send(message, SSDP_PORT, SSDP_ADDRESS);
  };

  // Notify every 5 minutes
  setInterval(notify, 5 * 60 * 1000);
  setTimeout(notify, 1000); // Initial announce

  return socket;
}
