#!/data/data/com.termux/files/usr/bin/bash

R='\033[31m'
G='\033[32m'
Y='\033[33m'
C='\033[36m'
N='\033[0m'

clear
echo -e "${C}MyTerminalOS Installer (Fixed)${N}"
sleep 0.5

function ok(){ echo -e "${G}✔${N} $1"; }
function load(){ echo -en "${Y}•${N} $1...\r"; sleep 0.7; }

pkg update -y >/dev/null 2>&1 && ok "update"
pkg upgrade -y >/dev/null 2>&1 && ok "upgrade"

for i in proot tar wget; do
    pkg install $i -y >/dev/null 2>&1 && ok "install $i"
done

mkdir -p MyTerminal
cd MyTerminal

load "download ubuntu"
wget -O ubuntu.tar.gz https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-arm64-root.tar.gz >/dev/null 2>&1 && ok "download ubuntu"

load "extract rootfs"
mkdir -p rootfs
tar -xzf ubuntu.tar.gz -C rootfs >/dev/null 2>&1 && ok "extract"
rm ubuntu.tar.gz

echo "nameserver 8.8.8.8" > rootfs/etc/resolv.conf
echo "nameserver 8.8.4.4" >> rootfs/etc/resolv.conf

cat > start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
ROOTFS=$(dirname $0)/rootfs
proot --link2symlink -0 -r $ROOTFS -b /dev -b /proc -b /sys -w /root /usr/bin/env -i HOME=/root PATH=/usr/bin:/usr/sbin:/bin:/sbin TERM=$TERM SHELL=/bin/bash /bin/bash --login
EOF
chmod +x start.sh
ok "launcher siap"

clear
echo -e "${G}★ Sukses Bang ★${N}"
echo -e "jalankan: ${Y}cd MyTerminal && ./start.sh${N}"
