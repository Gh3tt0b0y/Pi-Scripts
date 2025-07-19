# 🖨️ Enderon OS – Setup-Skript für Raspberry Pi 4 & 5

Dieses Skript richtet ein vollständiges 3D-Druck-System auf einem Raspberry Pi ein – optimiert für **Klipper**, **Fluidd**, **Crowsnest**, **SMB**, **FTP** und **Home Assistant Integration**.

---

## 🚀 Funktionen

- 📦 Installation von Systempaketen
- 🔁 Bind-Mounts für Klipper-Dateien nach `/srv/Enderon`
- 🖥️ FTP (vsftpd) & SMB (Samba) Zugriff auf:
  - `timelapse`
  - `modeldata`
  - `config`
  - `logs`
- 📡 Netzwerkdienste vorkonfiguriert (WLAN & LAN)
- 🛠️ Automatischer Start von [KIAUH](https://github.com/th33xitus/kiauh) zur einfachen Installation von:
  - Klipper
  - Moonraker
  - Fluidd (Port 80)
  - Mainsail (Port 82)
  - KlipperScreen
  - Crowsnest

---

## 📥 Installation

### 🔧 Voraussetzungen

- Raspberry Pi 4 oder 5
- Raspberry Pi OS **Lite 64 Bit**
- Benutzer `pi` mit SSH-Zugriff
- Internetverbindung

---

### 📦 Einzeiler zur Installation

Führe diesen Befehl **direkt über SSH als pi-Nutzer** aus:

```bash
sudo bash <(curl -s https://raw.githubusercontent.com/Gh3tt0b0y/Pi-Scripts/main/setup_klipperos_final.sh)
