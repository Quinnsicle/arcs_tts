const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.static('public'));
// also allow serving images placed directly in overlay_server/card_images/
app.use('/card_images', express.static('card_images'));

let sseClients = [];
let lastPayload = null;

function sendSse(data) {
  const msg = `data: ${JSON.stringify(data)}\n\n`;
  sseClients.forEach(res => res.write(msg));
}

app.post('/overlay', (req, res) => {
  const payload = req.body;
  lastPayload = payload;
  console.log('[overlay] received payload:', JSON.stringify(payload).slice(0, 1000));
  sendSse({ type: 'overlay_update', payload });
  res.json({ ok: true });
});

// Return last payload for quick polling
app.get('/last', (req, res) => {
  res.json(lastPayload || {});
});

// SSE endpoint for clients (OBS browser source can connect)
app.get('/events', (req, res) => {
  res.set({ 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache', Connection: 'keep-alive' });
  res.flushHeaders();
  // send a comment to keep connection alive initially
  res.write(': connected\n\n');
  sseClients.push(res);

  // send last payload immediately if exists
  if (lastPayload) {
    res.write(`data: ${JSON.stringify({ type: 'overlay_update', payload: lastPayload })}\n\n`);
  }

  req.on('close', () => {
    sseClients = sseClients.filter(r => r !== res);
  });
});

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

app.listen(port, () => {
  console.log(`Overlay server listening on http://localhost:${port}`);
});
