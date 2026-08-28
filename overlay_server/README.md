# ARCS TTS Overlay Server

This folder is intended to be a standalone Node.js project that can be cloned and run by itself.

It accepts POST requests at `/overlay` and broadcasts the latest payload to browser clients via Server-Sent Events at `/events`. The browser page at `/` renders a simple OBS-friendly overlay.

## Requirements

- **Node.js** (v14 or later recommended) — [Download from nodejs.org](https://nodejs.org)
  - This includes `npm`, which is used to install dependencies and run the server.

## Clone / Run

```bash
git clone <this-repo-or-standalone-overlay-server-repo>
cd overlay_server
npm install
npm start
```

If you keep it inside the mod repository, just run the same commands from this folder.

## Publishing Overlay-Only Updates From Monorepo

If you maintain this folder inside the main Arcs mod repo and also want to publish updates to a standalone overlay repo, use git subtree.

Add the standalone remote once (from the main repo root):

```bash
git remote add overlay-origin https://github.com/Laurens1234/arcs-tts-overlay-server.git
```

Push only this folder whenever you update the overlay:

```bash
git subtree push --prefix=overlay_server overlay-origin main
```

You can still push your main repo normally; this command only publishes the `overlay_server` folder to the standalone overlay repository.

## TTS Side

Make sure `src/SheetsSenderOverlay.lua` points `LOCAL_OVERLAY_URL` at your local server, usually:

```lua
http://127.0.0.1:3000/overlay
```

## OBS Side

Add a Browser Source pointing at:

```text
http://localhost:3000/
```

Set the source size as needed and keep the page background transparent if you want only the text overlay.

## What gets sent

Each payload contains a `players` array with:

- `steam_name`
- `color`
- `hand`
- `hand_size`

The TTS sender also prefers card descriptions when a card's name is generic, so cards like `Action Card` can render as their actual printed description.

## How It Works

The overlay displays the active player's hand in a compact, visual format:

- **Player cards**: Each player gets a row showing their hand as overlapping card images (only the top-left quarter of each card is visible, scaled up 3.2x)
- **Color stripe**: A thin 10px colored stripe shows the player's color on the left or right side of the row
- **Card stacking**: Cards overlap slightly so you can see how many are in hand at a glance
- **Real-time updates**: The overlay updates whenever a card is played or drawn, or when a player's turn begins
- **OBS-friendly**: Fixed positioning in the top-left corner with no fullscreen mode — perfect for streaming overlays

## Chat Commands

In the TTS table chat, use the following commands to control the overlay (type them all lowercase):

### Start/Stop Sending

| Command | Effect |
|---------|--------|
| `!overlay start` | Enable automatic sending — overlay updates each turn and when cards move |
| `!overlay stop` | Disable automatic sending — overlay stops updating |
| `!overlay once` | Send a single update immediately without changing the enabled state |
| `!overlay status` | Show whether overlay sending is currently enabled or disabled |

### Card Visibility

| Command | Effect |
|---------|--------|
| `!overlay hidecards` | Blank out all card images and show placeholder boxes instead |
| `!overlay showcards` | Show the actual card images again |
| `!overlay togglecards` | Toggle between showing and hiding card faces |

### Overlay Position

| Command | Effect |
|---------|--------|
| `!overlay align left` or `!overlay left` | Position overlay on the left side (default) |
| `!overlay align right` or `!overlay right` | Position overlay on the right side |

### Help

| Command | Effect |
|---------|--------|
| `!overlay help` | Display a list of all available commands in the chat |

## When the Overlay Updates

The overlay sends updates in the following situations:

1. **On turn change** (if sending is enabled) — when a new player's turn begins
2. **When cards enter the hand zone** — when a card is moved into a player's hand area
3. **When cards leave the hand zone** — when a card is played or removed from hand
4. **On chapter start** — reminds players that the overlay is on (green message)
5. **On manual commands** — `!overlay once` or any card visibility/alignment change sends an immediate update

## Payload Format

The server receives JSON payloads with this structure:

```json
{
  "source": "tts",
  "timestamp": 1234567890,
  "players": [
    {
      "steam_name": "PlayerName",
      "color": "White",
      "hand": ["Card Name 1", "Card Name 2"],
      "hand_size": 2
    }
  ],
  "turn_order": ["White", "Yellow", "Red", "Teal", "Pink"],
  "align": "left",
  "hide_cards": false
}
```

The browser client uses `turn_order` to sort players by their position in the turn sequence.

