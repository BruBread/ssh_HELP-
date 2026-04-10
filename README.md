# SSHIT!
**"Just get an HDMI bro"**

---

## How It Works

Once installed, your Pi broadcasts an open Wi-Fi network named after your username (e.g. `pi-john`).  
Connect your laptop to that network and SSH to `10.0.0.1` or `username@hostname.local`.

```
Laptop → connects to "pi-john" Wi-Fi → ssh john@10.0.0.1 → you're in
```

The AP turns off when you connect the Pi to a network via `piwifi` or `piconnect`.  
If that connection drops, the AP automatically comes back up on its own.

---

## First-Time Setup

You only need to SSH in the old way once to run the installer. After that, you never need to again.

### Step 1 — Flash Pi OS Lite

Download and flash **Raspberry Pi OS Lite (64-bit)** using  
[Raspberry Pi Imager](https://www.raspberrypi.com/software/)

Path:
> Raspberry Pi 4 → Other OS → Debian 64 Lite

Set:
- **Hostname:** `francispi` (or whatever you want — just keep it the same each time)
- **Username:** `francis` (or whatever you want — **keep this the same too!**)
- **Password** (remember this)
- **Your home Wi-Fi SSID and password**

> 💡 **Pro tip:** Use the same username and hostname every time you flash a Pi.  
> This way, SSH just works without editing `known_hosts` constantly.

This pre-configures SSH and Wi-Fi so the Pi connects on first boot.

---

### Step 2 — Boot the Pi

Insert the SD card (or USB drive), power on, wait ~60 seconds.

---

### Step 3 — SSH In (One Time Only)

Try this first:

```bash
ssh francis@francispi.local
```

(Replace `francis` and `francispi` with whatever you set in Step 1)

> Works on macOS/Linux. Unreliable on Windows — if it fails, log into your router and find the Pi's IP, then:
```bash
ssh francis@<ip>
```

---

### Step 4 — Install SSHit

Once you're in:

```bash
sudo apt install git
git clone https://github.com/BruBread/sshit.git
cd sshit
sudo bash install.sh
```

The installer will:
- install `hostapd` and `dnsmasq`
- configure a Wi-Fi AP named `pi-<yourusername>`
- add `pi*` commands to your shell
- set up auto-start and auto-recovery on every boot

After it finishes, reboot:

```bash
sudo reboot
```

Wait ~60 seconds.

---

### Step 5 — Connect the Easy Way (Forever)

1. Join Wi-Fi: **`pi-francis`** (no password)  
2. SSH in:

```bash
ssh francis@10.0.0.1
```

That’s it. No more finding the IP.

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
| `pisaved` | View and remove saved networks |
| `piadd [ssid] [password]` | Add a network to auto-connect list |
| `sudo piupdate` | Check for and install SSHit updates |
| `pirestart` | Reboot the Pi |

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

# Check for updates
sudo piupdate

# View and manage saved networks
pisaved

# Add a network without connecting now
piadd myssid mypassword

# Reboot the Pi
pirestart
```

---

## Supported Hardware

- Raspberry Pi 4 (all RAM variants)
- Pi OS Lite (Bookworm, 64-bit recommended)
- Also works booting from USB

---

## Troubleshooting

### "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

This happens if you reflash or reinstall. New OS = new SSH keys.

Fix (pick one):

```bash
# Option 1
ssh-keygen -R francispi.local

# Option 2
# Edit ~/.ssh/known_hosts and delete the line

# Option 3 (nuclear)
rm ~/.ssh/known_hosts   # macOS/Linux
del C:\Users\user\.ssh\known_hosts   # Windows
```

Then reconnect and type `yes`.

> 💡 This is why keeping the same hostname/username helps.

---

### AP isn't showing up

```bash
sudo piap
pistatus
```

---

### hostapd fails to start

```bash
sudo journalctl -u hostapd --no-pager -n 30
```

Usually `wlan0` is being held by NetworkManager or wpa_supplicant.  
`piap` normally fixes it — otherwise just reboot.

---

### Can't SSH after connecting to the AP

Make sure you're using:

```bash
ssh francis@10.0.0.1
```

(not the hostname)

---

### AP didn't come back after disconnect

```bash
sudo piap
```

Or just wait — watcher checks every ~10 seconds.

---

## Project Structure

```
sshit/
├── install.sh
├── picommands.sh
├── netwatcher.sh
└── README.md
```

---

## License

MIT
