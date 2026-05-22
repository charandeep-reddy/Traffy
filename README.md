# Traffy

A lightweight macOS menu bar app that displays real-time network upload and download speeds.

[![Download](https://img.shields.io/badge/Download-v1.0.0-brightgreen)](https://github.com/charandeep-reddy/traffy/releases/latest)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![MIT](https://img.shields.io/badge/license-MIT-green)

## Features

- **Real-time speeds** — upload and download displayed in the menu bar
- **Split/Combined mode** — show both speeds or just the active direction
- **Bytes/Bits** — toggle between B/s, KB/s, MB/s or b/s, Kbps, Mbps
- **Custom interval** — update every 1s, 2s, or 3s
- **Launch at Login** — automatically starts when you log in
- **No dock icon** — lives quietly in the menu bar (LSUIElement agent)

## Requirements

- macOS 13 or later (Ventura+)
- Apple Silicon or Intel Mac

## Installation

1. Download the latest `Traffy.dmg` from [Releases](https://github.com/charandeep-reddy/traffy/releases)
2. Open the DMG and drag `Traffy.app` to your Applications folder
3. Launch it — you'll see your network speeds in the menu bar
4. (Optional) Enable "Launch at Login" from the dropdown menu

## Build from Source

```bash
git clone https://github.com/charandeep-reddy/traffy.git
cd traffy
make dmg
```

The `.dmg` and `.app` will be created in the project root.

## Usage

Click the speed display in the menu bar to open the dropdown:

- **Mode** → Split (both speeds) or Combined (dominant direction only)
- **Unit** → Bytes or Bits
- **Interval** → 1s, 2s, or 3s update rate
- **Launch at Login** — toggle on/off
- **Quit** — exits the app

## How It Works

Traffy uses the `getifaddrs()` system API to read per-interface byte counters, then calculates deltas over the configured interval to derive speeds. No external dependencies — pure Swift + system frameworks.

## License

MIT
