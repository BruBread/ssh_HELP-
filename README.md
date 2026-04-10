# SSHIT!
**"Just get an HDMI bro"**
---

## How It Works

Once installed, your Pi broadcasts an open Wi-Fi network named after your username (e.g. `pi-john`). Connect your laptop to that network and SSH to `10.0.0.1`. Done forever.

```
Laptop → connects to "pi-john" Wi-Fi → ssh john@10.0.0.1 → you're in
```

The AP turns off when you connect the Pi to a network via `piwifi` or `piconnect`. If that connection drops, the AP automatically comes back up on its own.

---

## First-Time Setup

You only need to SSH in the old way once to run the installer. After that, you never need to again.

### Step 1 — Flash Pi OS Lite

Download and flash **Raspberry Pi OS Lite (64-bit)** using [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

Click the gear icon ⚙️ before flashing and set:
- **Hostname:** `francispi` (or whatever you want — just keep it the same each time)
- **Username:** `francis` (or whatever you want — **keep this the same too!**)
- **Password** (remember this)
- **Your home Wi-Fi SSID and password**

> **💡 Pro tip:** Use the **same username and hostname** every time you flash a Pi. This way, SSH just works without editing `known_hosts` constantly.

This pre-configures SSH and Wi-Fi so the Pi connects on first boot.

### Step 2 — Boot the Pi

Insert the SD card (or USB drive), power on, wait ~60 seconds.

### Step 3 — SSH In (One Time Only)

Try this first:
```bash
ssh francis@francispi.local
```
(Replace `francis` and `francispi` with whatever you set in Step 1)

> Works on macOS/Linux. Unreliable on Windows — if it fails, log into your router and find the Pi's IP in the device list, then use `ssh francis@<ip>`.

### Step 4 — Install SSHit

Once you're in:
```bash
sudo apt install git
git clone https://github.com/BruBread/sshit.git
cd sshit
sudo bash install.sh
```

The installer will:
- Install `hostapd` and `dnsmasq`
- Configure a Wi-Fi AP named `pi-<yourusername>`
- Add `pi*` commands to your shell
- Set up auto-start and auto-recovery on every boot

**After the installer finishes, reboot:**
```bash
sudo reboot
```

Wait ~60 seconds for the Pi to come back up.

### Step 5 — Connect the Easy Way, Forever

1. On your laptop, join Wi-Fi: **`pi-francis`** (no password)
2. SSH in: `ssh francis@10.0.0.1`

That's it. You never need to find the IP again.

---

## Commands

| Command | Description |
|---|---|
| `pihelp` | Show all commands |
| `pistatus` | Current mode, IPs, connected clients |
| `sudo piap` | Switch back to AP mode |
| `sudo pilock [password]` | Add a password to the AP |
| `sudo piunlock` | Remove AP password (open network) |
| `sudo piwifi` | Scan and connect to a Wi-Fi network |
| `sudo piconnect <ssid> [pw]` | Connect to a specific network |

### Examples

```bash
# See what's going on
pistatus

# Add a password to the AP
sudo pilock mysecretpass
# (or just run sudo pilock and it'll prompt you)

# Connect Pi to your home network
sudo piwifi

# Switch back to AP mode manually
sudo piap
```

---

## Supported Hardware

- Raspberry Pi 4 (all RAM variants)
- Pi OS Lite (Bookworm, 64-bit recommended)
- Also works booting from USB drive

---

## Troubleshooting

**"WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!" when connecting**

This is normal if you've reflashed the Pi or reinstalled the OS. The Pi generated new SSH keys, so your computer sees a different fingerprint.

**Fix (pick one):**
```bash
# Option 1 - Remove the old key for this hostname
ssh-keygen -R francispi.local

# Option 2 - Edit ~/.ssh/known_hosts and delete the line for francispi.local

# Option 3 - Remove all saved hosts (nuclear option)
rm ~/.ssh/known_hosts   # macOS/Linux
del C:\Users\user\.ssh\known_hosts   # Windows
```

After doing this, SSH again and type `yes` when asked to confirm the new fingerprint.

> **💡 This is why you should use the same username and hostname every time** — fewer conflicts in `known_hosts`!

---

**AP isn't showing up**
```bash
sudo piap       # restart the AP
pistatus        # check what's going on
```

**`hostapd` fails to start**
```bash
sudo journalctl -u hostapd --no-pager -n 30
```
Most common cause: NetworkManager or wpa_supplicant is holding `wlan0`. `piap` handles this automatically, but a reboot fixes stubborn cases.

**Can't SSH after connecting to the AP**

Make sure you're using `10.0.0.1`, not the hostname:
```bash
ssh francis@10.0.0.1
```

**Pi connected to network but AP didn't come back after disconnect**
```bash
sudo piap   # bring it back manually
# or wait — the watcher checks every 10 seconds and will restore it
```

---

## Project Structure

```
sshit/
├── install.sh        # Installer — run this first
├── picommands.sh     # All pi* shell commands (sourced by .bashrc)
├── netwatcher.sh     # Background watcher — restores AP on disconnect
└── README.md
```

---

## License

MIT
