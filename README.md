# ssh_HELP-
Made because people in my class found it difficult to SSH into their Raspberry pi 4's

# PiAccess

**Dead-simple SSH access to your headless Raspberry Pi. Forever.**

No more hunting for IP addresses. Your Pi broadcasts its own Wi-Fi hotspot. Connect to it, SSH in. Done.

---

## How It Works

Once installed, your Pi broadcasts an open Wi-Fi network named after your username (e.g. `pi-john`). Connect your laptop to that network and SSH to `10.0.0.1`. The Pi's AP stays on permanently — even after reboots — alongside your normal home Wi-Fi connection.

```
Laptop → connects to "pi-john" Wi-Fi → ssh john@10.0.0.1 → you're in
```

---

## First-Time Setup (One-Time Steps)

Before installing PiAccess, you need to SSH in just once the old way. Here's how.

### Step 1 — Flash Pi OS Lite

Download and flash **Raspberry Pi OS Lite (64-bit)** using [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

In the Imager, click the gear icon ⚙️ and set:
- Hostname: `raspberrypi`
- Username and password (remember these)
- Your home Wi-Fi SSID and password

This pre-configures SSH and Wi-Fi so you can connect on first boot.

### Step 2 — Boot the Pi

Insert the SD card, power on the Pi, and wait ~60 seconds.

### Step 3 — Find the Pi on Your Network (One Time Only)

Try these in order until one works:

```bash
ssh yourname@raspberrypi.local      # Works on macOS/Linux, unreliable on Windows
```

If that fails, log into your router and find the Pi's IP in the device list, then:

```bash
ssh yourname@<pi-ip-address>
```

### Step 4 — Install PiAccess

Once you're SSHed in:

```bash
curl -sSL https://raw.githubusercontent.com/BruBread/piaccess/main/install.sh | sudo bash
```

That's it. The installer:
- Installs `hostapd` and `dnsmasq`
- Starts a Wi-Fi AP named `pi-<yourusername>`
- Adds `pi*` commands to your shell
- Enables the AP to auto-start on every boot

### Step 5 — Connect the Easy Way, Forever

From now on, never hunt for an IP again:

1. On your laptop, connect to Wi-Fi: **`pi-yourusername`** (no password by default)
2. SSH in: `ssh yourusername@10.0.0.1`

---

## Commands

| Command | Description |
|---|---|
| `pihelp` | Show all commands |
| `pistatus` | AP status, IP addresses, connected clients |
| `piap` | Restart the access point |
| `pilock [password]` | Add a password to the AP |
| `piunlock` | Remove AP password (go back to open) |
| `piwifi` | Scan and connect to a Wi-Fi network interactively |
| `piconnect <ssid> [pw]` | Connect to a specific Wi-Fi network |
| `piupdate` | Pull the latest version from GitHub |

### Examples

```bash
# Check everything at a glance
pistatus

# Lock the AP with a password
sudo pilock mysecretpass

# Or just run pilock and it will prompt you
sudo pilock

# Connect to a new home Wi-Fi network
piwifi

# Update PiAccess to the latest version
piupdate
```

---

## Supported Hardware

- Raspberry Pi 4 (all RAM variants)
- Pi OS Lite (Bookworm, 64-bit recommended)

---

## Troubleshooting

**The AP isn't showing up**
```bash
sudo piap          # restart the AP
pistatus           # check what's happening
```

**`hostapd` fails to start**
```bash
sudo journalctl -u hostapd --no-pager -n 30
```
Most common cause: another process (NetworkManager, wpa_supplicant) is holding `wlan0`. `piap` handles this automatically but a reboot fixes persistent issues.

**I can't SSH after connecting to the AP**

Make sure you're SSHing to `10.0.0.1`, not the Pi's hostname:
```bash
ssh yourname@10.0.0.1
```

**I want to re-run the installer**

The installer is idempotent — safe to run multiple times:
```bash
curl -sSL https://raw.githubusercontent.com/BruBread/piaccess/main/install.sh | sudo bash
```

---

## Project Structure

```
piaccess/
├── install.sh        # One-line installer, entry point
├── picommands.sh     # All pi* bash functions (sourced by .bashrc)
└── README.md
```

---

## License

MIT
