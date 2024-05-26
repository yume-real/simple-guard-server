#!/bin/bash

discord_webhook_url="YOUR_WEBHOOK_URL"

role_id="YOUR_ROLE_ID"

get_vps_ip() {
  hostname -I | awk '{print $1}'
}

send_to_discord() {
  local message="$1"
  local timestamp="$2"
  local username="$3"
  local user_ip_address="$4"
  local vps_ip_address="$5"
  
  json_payload=$(jq -n \
    --arg content "<@&$role_id>" \
    --arg title "New connection on SSH" \
    --arg time "$timestamp" \
    --arg user "$username" \
    --arg user_ip "$user_ip_address" \
    --arg vps_ip "$vps_ip_address" \
    '{
       "content": $content,
       "embeds": [
         {
           "title": $title,
           "color": 3066993,
           "fields": [
             {
               "name": "Time",
               "value": $time,
               "inline": true
             },
             {
               "name": "User",
               "value": $user,
               "inline": true
             },
             {
               "name": "IP-adress of user",
               "value": $user_ip,
               "inline": true
             },
             {
               "name": "IP-adress of VPS",
               "value": $vps_ip,
               "inline": true
             }
           ]
         }
       ]
     }')
     
  curl -H "Content-Type: application/json" -X POST -d "$json_payload" "$discord_webhook_url"
}

while true; do
  current_hour=$(TZ='Europe/Moscow' date +%H)
  
  if [ "$current_hour" -ge 0 ] && [ "$current_hour" -lt 8 ]; then
    ufw deny ssh
  else
    ufw allow ssh
  fi
  
  vps_ip_address=$(get_vps_ip)

  for ((i=0; i<360; i++)); do
    auth_log="/var/log/auth.log"
    offset_file="/var/log/auth_offset"

    get_last_line() {
      if [ -f "$offset_file" ]; then
        cat "$offset_file"
      else
        echo 0
      fi
    }

    save_last_line() {
      echo "$1" > "$offset_file"
    }

    last_line=$(get_last_line)
    new_entries=$(tail -n +$((last_line + 1)) "$auth_log" | grep "Accepted ")
    lines_count=$(tail -n +$((last_line + 1)) "$auth_log" | wc -l)

    if [ -n "$new_entries" ]; then
      while IFS= read -r entry; do
        timestamp=$(echo "$entry" | awk '{print $1, $2, $3}')
        username=$(echo "$entry" | awk '{print $9}')
        user_ip_address=$(echo "$entry" | awk '{print $11}')
        
        send_to_discord "$entry" "$timestamp" "$username" "$user_ip_address" "$vps_ip_address"
      done <<< "$new_entries"
      save_last_line $((last_line + lines_count))
    fi

    sleep 10
  done

done