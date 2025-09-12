#!/usr/bin/env bash
set -euo pipefail

# ==== Konfig via env ====
: "${CF_API_TOKEN:=}"
: "${CF_ZONE_NAME:=}"           	# Zone
: "${DNS_NAME:=}"         		# FQDN to update
: "${PROXIED:=true}"                    # true|false (orange cloud)
: "${TTL:=1}"				# 1 = auto

API="https://api.cloudflare.com/client/v4"

hdr=(-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json")

# Finn zone_id for sonen
zone_id=$(curl -fsS "${API}/zones?name=${CF_ZONE_NAME}" "${hdr[@]}" | jq -r '.result[0].id')
if [[ -z "${zone_id}" || "${zone_id}" == "null" ]]; then
  echo "zone_id for ${CF_ZONE_NAME} not found"; exit 1
fi

# Get IP's
ipv4=$(curl -fsS https://ipv4.icanhazip.com/ | tr -d '\n\r' || true)
ipv6=$(curl -fsS https://ipv6.icanhazip.com/ | tr -d '\n\r' || true)

update_record () {
  local TYPE="$1" CONTENT="$2"
  [[ -z "${CONTENT}" ]] && return 0

  # Finn eksisterende record-id
  rec_json=$(curl -fsS "${API}/zones/${zone_id}/dns_records?type=${TYPE}&name=${DNS_NAME}" "${hdr[@]}")
  rec_id=$(echo "$rec_json" | jq -r '.result[0].id')
  current=$(echo "$rec_json" | jq -r '.result[0].content // empty')

  if [[ -n "${rec_id}" && "${rec_id}" != "null" ]]; then
    if [[ "${current}" == "${CONTENT}" ]]; then
      echo "${TYPE}: unchanged (${CONTENT})"
    else
      echo "Updating ${TYPE} -> ${CONTENT}"
      curl -fsS -X PUT "${API}/zones/${zone_id}/dns_records/${rec_id}" "${hdr[@]}" \
        --data "$(jq -n --arg type "$TYPE" --arg name "$DNS_NAME" --arg content "$CONTENT" --argjson proxied ${PROXIED} --argjson ttl ${TTL} \
                 '{type:$type,name:$name,content:$content,proxied:$proxied,ttl:$ttl}')" >/dev/null
    fi
  else
    echo "Creating ${TYPE} -> ${CONTENT}"
    curl -fsS -X POST "${API}/zones/${zone_id}/dns_records" "${hdr[@]}" \
      --data "$(jq -n --arg type "$TYPE" --arg name "$DNS_NAME" --arg content "$CONTENT" --argjson proxied ${PROXIED} --argjson ttl ${TTL} \
               '{type:$type,name:$name,content:$content,proxied:$proxied,ttl:$ttl}')" >/dev/null
  fi
}

# Requires jq
command -v jq >/dev/null || { echo "Install jq"; exit 1; }

update_record "A"    "${ipv4}"
update_record "AAAA" "${ipv6}"

echo "Completed for ${DNS_NAME} in zone ${CF_ZONE_NAME}"
