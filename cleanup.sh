#!/bin/bash
# cleanup.sh — ChrisOS Wi-Fi Exfil Tool Cleanup Utility

# ──────── COLORS & STYLES ─────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ──────── CHECK IF RUN FROM TOOL ROOT ─────────
if [[ ! -f "launch.sh" || ! -d "captures" || ! -d "payloads" ]]; then
    echo -e "${RED}❌ ERROR: Not in tool root directory${NC}" >&2
    echo -e "${YELLOW}Run this script from the wifi-exfil-tool directory${NC}" >&2
    exit 1
fi

# ──────── STOP PROCESSES ─────────
stop_processes() {
    echo -e "${CYAN}[1/4]${NC} Stopping background processes..."
    
    # Kill cloudflared and server processes by name (safer than PIDs)
    pids_to_kill=($(pgrep -f "cloudflared tunnel") $(pgrep -f "server.py"))
    if [ ${#pids_to_kill[@]} -gt 0 ]; then
        kill "${pids_to_kill[@]}" 2>/dev/null
        sleep 1  # Brief pause before checking
        # Force kill any remaining
        kill -9 $(pgrep -f "cloudflared tunnel" 2>/dev/null) 2>/dev/null || true
        kill -9 $(pgrep -f "server.py" 2>/dev/null) 2>/dev/null || true
        echo -e "${GREEN}✓ Processes terminated${NC}"
    else
        echo -e "${YELLOW}⚠ No matching processes found${NC}"
    fi
}

# ──────── CLEAR LOGS ─────────
clear_logs() {
    echo -e "${CYAN}[2/4]${NC} Clearing logs..."
    
    # Clear captures directory
    if [ -d "captures" ] && [ "$(ls -A captures 2>/dev/null)" ]; then
        rm -rf captures/*
        echo -e "${GREEN}✓ Capture logs cleared${NC}"
    else
        echo -e "${YELLOW}⚠ No capture logs to clear${NC}"
    fi
    
    # Remove temp logs
    rm -f /tmp/cfd.log 2>/dev/null
    echo -e "${GREEN}✓ Temp logs removed${NC}"
}

# ──────── CLEAR PAYLOADS ─────────
clear_payloads() {
    echo -e "${CYAN}[3/4]${NC} Clearing generated payloads..."
    
    if [ -d "payloads" ] && [ "$(ls -A payloads 2>/dev/null)" ]; then
        rm -rf payloads/*
        echo -e "${GREEN}✓ Payloads cleared${NC}"
    else
        echo -e "${YELLOW}⚠ No payloads to clear${NC}"
    fi
}

# ──────── FULL CLEANUP ─────────
full_cleanup() {
    echo -e "${CYAN}[4/4]${NC} Performing full cleanup..."
    
    # Remove cloudflared binary and directory
    if [ -d "cloudflared" ]; then
        rm -rf cloudflared/
        echo -e "${GREEN}✓ Cloudflared binary removed${NC}"
    else
        echo -e "${YELLOW}⚠ No cloudflared directory to remove${NC}"
    fi
    
    # Remove any cached files (add more patterns as needed)
    rm -f .env 2>/dev/null || true
    echo -e "${GREEN}✓ Full cleanup completed${NC}"
}

# ──────── MAIN LOGIC ─────────
if [ "$1" = "--full" ]; then
    echo -e "
${GREEN}🧹 FULL CLEANUP INITIATED${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    stop_processes
    clear_logs
    clear_payloads
    full_cleanup
    echo -e "
${GREEN}✅ FULL CLEANUP COMPLETE${NC}"
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo -e "
${CYAN}📖 USAGE:${NC}
   ./cleanup.sh         # Stop processes & clear logs/payloads
   ./cleanup.sh --full  # Full cleanup (includes cloudflared binary)
   ./cleanup.sh --help  # Show this help

${LIME}💡 NOTES:${NC}
   • Run from tool root directory (where launch.sh is located)
   • Safe to run multiple times
   • --full does NOT remove launch.sh, server.py, or templates/
"
else
    echo -e "
${GREEN}🧹 STANDARD CLEANUP INITIATED${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    stop_processes
    clear_logs
    clear_payloads
    echo -e "
${GREEN}✅ STANDARD CLEANUP COMPLETE${NC}"
    echo -e "${YELLOW}💡 Run './cleanup.sh --full' to remove cloudflared binary${NC}"
fi