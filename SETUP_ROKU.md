# JBTV Roku Setup Guide

Complete walkthrough to get JBTV running on your Roku TV, starting from a factory-default TV.

---

## Prerequisites

- A Roku TV connected to your Wi-Fi
- A laptop/computer on the **same Wi-Fi network**
- Node.js 18+ installed on the laptop (`node --version` to check)
- The JBTV repo cloned on the laptop

---

## Step 1: Find Your Laptop's IP Address

You'll need this so the Roku can talk to your server.

**Mac:**
```bash
ipconfig getifaddr en0
```

IP: 10.0.0.23

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your Wi-Fi adapter.

**Linux:**
```bash
hostname -I | awk '{print $1}'
```

Write this down. It'll look something like `192.168.1.42`.

---

## Step 2: Set Up the JBTV Server

```bash
cd server
cp config.example.json config.json
```

Open `config.json` and set your name:
```json
{
  "user": {
    "name": "Joseph"
  }
}
```

Optionally fill in API keys (see `API_KEYS.md`). The server works without them — you'll get clock, quotes, countdowns, news, sports, and stock tickers right away.

Install dependencies and start the server:
```bash
npm install
npm run dev
```

You should see:
```
JBTV server running at http://192.168.1.42:8888
Dashboard: http://192.168.1.42:8888/api/dashboard
```

Verify it works by opening that dashboard URL in your browser. You should see JSON data.

**Leave this terminal running.** The server needs to stay on for the Roku to fetch data.

---

## Step 3: Point the Roku Channel at Your Server

Open `roku/source/constants.brs` and change the IP to match your laptop's IP from Step 1:

```brightscript
SERVER_URL: "http://192.168.1.42:8888"
```

Replace `192.168.1.42` with your actual IP.

---

## Step 4: Enable Developer Mode on Your Roku

This is a one-time setup. Grab your Roku remote.

1. **Go to the Roku home screen** (press the Home button)
2. **Enter the secret code on your remote — press these buttons in order:**

   ```
   Home  Home  Home  Up  Up  Right  Left  Right  Left  Right
   ```

   That's: **Home 3 times, Up 2 times, Right, Left, Right, Left, Right**

3. A **Developer Settings** dialog will appear on screen
4. Select **Enable installer and restart**
5. Read the Developer Tools License Agreement and select **I Agree**
6. **Set a developer password** — you'll be prompted to create one. Pick something simple you'll remember (e.g. `jbtv1234`). Write this down.
7. The Roku will reboot. Wait for it to come back to the home screen.

**You only do this once.** Developer mode stays enabled until you factory reset.

---

## Step 5: Find Your Roku's IP Address

On your Roku TV:

1. Press **Home** on the remote
2. Go to **Settings**
3. Go to **Network**
4. Select **About**
5. Your IP address is listed (e.g. `192.168.1.55`)

Roku TV IP Address: 10.0.0.246

Write this down.

**Quick check:** Open `http://<ROKU_IP>` in your laptop's browser. You should see the Roku developer installer page with a purple banner. If you see this, you're good.

---

## Step 6: Package the Channel

Back on your laptop, in a new terminal:

```bash
cd /path/to/jbtv
chmod +x tools/package.sh
./tools/package.sh
```

This creates `tools/jbtv.zip` — the sideloadable channel package.

---

## Step 7: Sideload JBTV onto the Roku

**Option A — Use the deploy script (recommended):**

```bash
chmod +x tools/deploy.sh
./tools/deploy.sh <ROKU_IP> <DEV_PASSWORD>
```

For example:
```bash
./tools/deploy.sh 192.168.1.55 jbtv1234
```

If it says `Install Success`, you're done.

**Option B — Use the web installer:**

1. Open `http://<ROKU_IP>` in your browser
2. You'll be prompted for credentials:
   - Username: `rokudev`
   - Password: the developer password you set in Step 4
3. Click **Upload** and select `tools/jbtv.zip`
4. Click **Install**
5. The channel will install and launch automatically

---

## Step 8: Launch JBTV

After sideloading, JBTV should launch automatically. If it doesn't:

1. Press **Home** on your remote
2. Scroll down on the home screen — sideloaded channels appear at the **bottom** of your channel list
3. Select **JBTV** (you'll see your red logo)

You should see the splash screen, then the dashboard loads with your data.

---

## Updating JBTV After Making Changes

Whenever you change Roku code (anything in the `roku/` folder):

```bash
./tools/package.sh && ./tools/deploy.sh <ROKU_IP> <DEV_PASSWORD>
```

Server changes (`server/` folder) take effect immediately since `nodemon` auto-restarts.

---

## Troubleshooting

### "Loading..." screen never goes away
- Is your server running? Check the terminal where you ran `npm run dev`
- Can the Roku reach your server? The Roku and laptop must be on the **same Wi-Fi network**
- Did you update the IP in `roku/source/constants.brs`? It must match your laptop's IP exactly
- Firewall blocking port 8888? On Mac: System Settings > Network > Firewall > allow Node.js. On Windows: allow through Windows Defender Firewall

### Developer mode code doesn't work
- Make sure you're on the **home screen** before entering the code (not inside an app)
- Press the buttons deliberately, one at a time — don't rush
- If it still doesn't work, try: **Home Home Home Up Up Right Left Right Left Right** (some older guides show a slightly different sequence, but this is the current one)

### "Install Failure" when sideloading
- Make sure `manifest` is at the root of the zip, not inside a subfolder. The `package.sh` script handles this correctly
- Try deleting the existing channel first: go to `http://<ROKU_IP>/plugin_install`, log in, and click **Delete** before reinstalling

### Channel disappears after Roku update
- Roku system updates sometimes remove sideloaded channels. Just re-run the deploy script to reinstall

### Can't reach Roku web interface
- Double-check the IP address in Settings > Network > About
- Make sure your laptop is on the same network
- Developer mode might have been disabled — re-enter the secret code from Step 4

### Server shows "WARN: Weather module disabled..."
- That's normal if you haven't added API keys yet. See `API_KEYS.md` to set them up. The dashboard still works — those modules just show as empty

---

## Keeping JBTV Running 24/7

For the server to always be available when you turn on the TV:

**Mac (launchd):**
```bash
# Create a launch agent
cat > ~/Library/LaunchAgents/com.jbtv.server.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jbtv.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/node</string>
        <string>index.js</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/path/to/jbtv/server</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/jbtv.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/jbtv-error.log</string>
</dict>
</plist>
EOF

# Update the path, then load it
launchctl load ~/Library/LaunchAgents/com.jbtv.server.plist
```

**Linux (systemd):**
```bash
sudo tee /etc/systemd/system/jbtv.service << 'EOF'
[Unit]
Description=JBTV Server
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/jbtv/server
ExecStart=/usr/bin/node index.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable jbtv
sudo systemctl start jbtv
```

---

## Quick Reference

| Thing | Value |
|-------|-------|
| Roku dev mode code | Home Home Home Up Up Right Left Right Left Right |
| Roku dev username | `rokudev` |
| Server default port | `8888` |
| Roku web installer | `http://<ROKU_IP>/` |
| Dashboard endpoint | `http://<LAPTOP_IP>:8888/api/dashboard` |
| Health check | `http://<LAPTOP_IP>:8888/health` |
