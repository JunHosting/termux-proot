#!/data/data/com.termux/files/usr/bin/bash

# Palette
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
B='\033[1;34m'
W='\033[1;37m'
GR='\033[1;30m'
N='\033[0m'

# Verified Badge (SkyBlue + White)
V_BG='\033[48;5;39m'
V_FG='\033[1;97m'
VERIFIED="${V_BG}${V_FG} ✓ ${N}"

clear

# Banner
echo -e "${C}┌────────────────────────────────────────────────────────┐${N}"
echo -e "${C}│${N}                                                    "  
echo -e "${C}│${N}           ${W}YT : ${B}JUN OFFICIAL              "
echo -e "${C}│${N}                                             "
echo -e "${C}│${N}     ${GR}Creator  : ${W}Jun Official${N}                  "
echo -e "${C}│${N}     ${GR}Telegram : ${B}@JunMoods${N}                      "      
echo -e "${C}│${N}     ${GR}Status   : ${G}Premium script${N}              "
echo -e "${C}│${N}                                                        "
echo -e "${C}└────────────────────────────────────────────────────────┘${N}"
echo ""

# Functions
function load() {
    echo -ne "${Y}[wait]${N} $1...\r"
}

function ok() { 
    echo -e "${G}[ ok ]${N} $1"
}

function step() {
    echo -e "\n${C}┌─[${N} $1 ${C}]${N}"
}

# System Update
step "System Initialization"
load "Updating repositories"
pkg update -y >/dev/null 2>&1
ok "Repositories updated"

load "Upgrading packages"
pkg upgrade -y >/dev/null 2>&1
ok "Packages upgraded"

# Dependencies
step "Installing Dependencies"
for pkg in proot tar wget openssl; do
    load "Installing $pkg"
    pkg install $pkg -y >/dev/null 2>&1
    ok "Installed $pkg"
done

# Setup Directory
INSTALL_DIR="$HOME/MyTerminal"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

# Download Rootfs
step "Downloading Ubuntu Core"
if [ -f "ubuntu.tar.gz" ]; then
    rm ubuntu.tar.gz
fi

echo -e "${GR}Downloading image from Canonical server...${N}"
wget -q --show-progress -O ubuntu.tar.gz https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-arm64-root.tar.gz

if [ ! -f "ubuntu.tar.gz" ]; then
    echo -e "${R}[fail] Download failed. Check internet connection.${N}"
    exit 1
fi
ok "Download complete"

# Extraction
step "Extracting Filesystem"
load "Decompressing rootfs (Do not close)"
mkdir -p rootfs
proot --link2symlink tar -xzf ubuntu.tar.gz -C rootfs --exclude='dev' || :
rm ubuntu.tar.gz
ok "Extraction complete"

# DNS Config
echo "nameserver 8.8.8.8" > rootfs/etc/resolv.conf
echo "nameserver 8.8.4.4" >> rootfs/etc/resolv.conf

# Create Launcher
step "Finalizing Setup"
cat > start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
C='\033[1;36m'
Y='\033[1;33m'
B='\033[1;34m'
N='\033[0m'
clear
echo -e "${C}┌──────────────────────────────────────────┐${N}"
echo -e "${C}│${Y}       MyTerminalOS - Ubuntu Focal        ${C}│${N}"
echo -e "${C}└──────────────────────────────────────────┘${N}"
echo -e "${B}Welcome back, Jun Official User!${N}"
echo ""
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $(dirname $0)/rootfs"
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/bin:/usr/sbin:/bin:/sbin"
command+=" TERM=$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
exec $command
EOF

chmod +x start.sh
ok "Launcher created"

# Create Alias
if ! grep -q "gascoy" "$HOME/.bashrc"; then
    echo "alias gascoy='bash MyTerminal/start.sh'" >> "$HOME/.bashrc"
    ok "Alias 'gascoy' added to .bashrc"
else
    ok "Alias already exists"
fi

# Completion
clear
echo -e "${C}┌────────────────────────────────────────────────────────┐${N}"
echo -e "${C}│${N}                                                        ${C}│${N}"
echo -e "${C}│${G}             INSTALLATION SUCCESSFUL ${VERIFIED}               ${C}│${N}"
echo -e "${C}│${N}                                                        ${C}│${N}"
echo -e "${C}│${N}    ${W}Command to start:${N}                                   ${C}│${N}"
echo -e "${C}│${N}    ${B}gascoy${N}                                              ${C}│${N}"
echo -e "${C}│${N}                                                        ${C}│${N}"
echo -e "${C}│${N}    ${GR}User/Pass : root / (none)${N}                           ${C}│${N}"
echo -e "${C}│${N}                                                        ${C}│${N}"
echo -e "${C}└────────────────────────────────────────────────────────┘${N}"
echo ""
# Refresh bashrc for immediate use
source "$HOME/.bashrc" 2>/dev/null
