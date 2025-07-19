#!/bin/bash

# ================================
# Enderon OS Setup-Skript
# Raspberry Pi 4/5 mit Klipper + Tools
# ================================

# Farben für Ausgaben
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

echo -e "${GREEN}Starte Enderon OS Setup für Raspberry Pi...${NC}"

# -------------------------------
# 1. Root-Rechte prüfen
# -------------------------------
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Bitte führe dieses Skript mit sudo aus!${NC}"
  exit 1
fi

# -------------------------------
# 2. System aktualisieren
# -------------------------------
echo -e "${YELLOW}➤ Aktualisiere Systempakete...${NC}"
apt update && apt upgrade -y

# -------------------------------
# 3. Notwendige Pakete installieren
# -------------------------------
echo -e "${YELLOW}➤ Installiere benötigte Pakete...${NC}"
apt install -y git curl unzip build-essential python3 python3-pip python3-dev python3-venv \
               nginx lighttpd fcgiwrap vsftpd samba sudo avahi-daemon i2c-tools dialog

# -------------------------------
# 4. Benutzerpfade und Mount-Ziele erstellen
# -------------------------------
USER_HOME="/home/pi"
PRINTER_DATA="$USER_HOME/printer_data"
FTP_BASE="/mnt/ftpbinds"
FTP_LINK="/srv/Enderon"

echo -e "${YELLOW}➤ Erstelle Verzeichnisse für Bind-Mounts und Druckdaten...${NC}"
mkdir -p $PRINTER_DATA/{config,gcodes,timelapse,logs}
chown -R pi:pi /home/pi/printer_data
mkdir -p $FTP_BASE/{config,modeldata,timelapse,logs}
mkdir -p $FTP_LINK

# -------------------------------
# 5. Bind-Mounts in /etc/fstab eintragen
# -------------------------------
echo -e "${YELLOW}➤ Richte Bind-Mounts ein...${NC}"
echo "$PRINTER_DATA/config     $FTP_BASE/config     none bind 0 0" >> /etc/fstab
echo "$PRINTER_DATA/gcodes     $FTP_BASE/modeldata  none bind 0 0" >> /etc/fstab
echo "$PRINTER_DATA/timelapse  $FTP_BASE/timelapse  none bind 0 0" >> /etc/fstab
echo "$PRINTER_DATA/logs       $FTP_BASE/logs       none bind 0 0" >> /etc/fstab

mount -a

# -------------------------------
# 6. Erstelle symbolische Links nach /srv/Enderon
# -------------------------------
echo -e "${YELLOW}➤ Binde FTP-Verzeichnisse über /srv/Enderon ein (bind mounts)...${NC}"

mount --bind $PRINTER_DATA/config     $FTP_LINK/config
mount --bind $PRINTER_DATA/gcodes     $FTP_LINK/modeldata
mount --bind $PRINTER_DATA/timelapse  $FTP_LINK/timelapse
mount --bind $PRINTER_DATA/logs       $FTP_LINK/logs

# Dauerhaft in /etc/fstab eintragen, falls noch nicht vorhanden:
grep -qxF "$PRINTER_DATA/config $FTP_LINK/config none bind 0 0" /etc/fstab || echo "$PRINTER_DATA/config $FTP_LINK/config none bind 0 0" >> /etc/fstab
grep -qxF "$PRINTER_DATA/gcodes $FTP_LINK/modeldata none bind 0 0" /etc/fstab || echo "$PRINTER_DATA/gcodes $FTP_LINK/modeldata none bind 0 0" >> /etc/fstab
grep -qxF "$PRINTER_DATA/timelapse $FTP_LINK/timelapse none bind 0 0" /etc/fstab || echo "$PRINTER_DATA/timelapse $FTP_LINK/timelapse none bind 0 0" >> /etc/fstab
grep -qxF "$PRINTER_DATA/logs $FTP_LINK/logs none bind 0 0" /etc/fstab || echo "$PRINTER_DATA/logs $FTP_LINK/logs none bind 0 0" >> /etc/fstab

# -------------------------------
# 7. Konfiguriere FTP (vsftpd)
# -------------------------------
echo -e "${YELLOW}➤ Konfiguriere FTP-Server...${NC}"
cat <<EOF > /etc/vsftpd.conf
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_min_port=40000
pasv_max_port=50000
EOF

systemctl enable vsftpd
systemctl restart vsftpd

# -------------------------------
# 8. Konfiguriere SMB (Samba)
# -------------------------------
echo -e "${YELLOW}➤ Konfiguriere Samba-Netzwerkfreigabe...${NC}"
cat <<EOF >> /etc/samba/smb.conf

[Enderon]
   path = /srv/Enderon
   valid users = pi
   read only = no
   browseable = yes
EOF

(echo "raspberry"; echo "raspberry") | smbpasswd -s -a pi
systemctl restart smbd

# -------------------------------
# 9. Klipper-Setup via KIAUH
# -------------------------------
echo -e "${YELLOW}➤ Klone und starte KIAUH für Klipper-Installation...${NC}"
sudo -u pi bash -c "
cd ~
git clone https://github.com/th33xitus/kiauh.git
cd kiauh
./kiauh.sh
"

# -------------------------------
# Abschlussmeldung
# -------------------------------
echo -e "${GREEN}✅ Enderon OS Setup abgeschlossen!${NC}"
echo -e "${GREEN}➤ Du kannst jetzt über KIAUH Klipper, Moonraker, Fluidd, KlipperScreen und Crowsnest installieren.${NC}"
