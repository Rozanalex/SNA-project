#!/usr/bin/env bash
set -euo pipefail

IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
if [[ -z "$IFACE" ]]; then
  echo "ERROR: не удалось определить default-интерфейс" >&2
  exit 1
fi
echo "[*] Detected interface: $IFACE"

CIDR=$(ip -o -f inet addr show dev "$IFACE" \
       | awk '{print $4}' \
       | sed 's|/[0-9]*$|/&/|;s|\(.*\)/.*|\1|;s|/|\/|g' \
       | head -n1)
CIDR=$(ip -o -f inet addr show dev "$IFACE" | awk '{print $4}' | head -n1)
if [[ -z "$CIDR" ]]; then
  echo "ERROR: не удалось получить CIDR для $IFACE" >&2
  exit 1
fi
echo "[*] Detected subnet: $CIDR"

YAML=suricata/suricata.yaml

sed -i -E "s|^([[:space:]]*HOME_NET:).*|\1 \"[$CIDR]\"|" "$YAML"

sed -i -E "s|^([[:space:]]*EXTERNAL_NET:).*|\1 \"! \$HOME_NET\"|" "$YAML"
echo "[*] Updated $YAML → HOME_NET: [$CIDR], EXTERNAL_NET: ! \$HOME_NET"


DC=docker-compose.yml
if grep -q '"-i"' "$DC"; then
  sed -i -E "s#(\"-i\"[[:space:]]*,[[:space:]]*\")[^\"]*(\")#\1$IFACE\2#g" "$DC"
  echo "[*] Updated $DC → interface: $IFACE"
else
  echo "WARN: не нашёл '-i' в $DC, проверьте секцию command"
fi


echo "[*] Bringing down existing stack…"
if ! docker compose down; then
  echo "[*] Попытка с sudo…"
  sudo docker compose down
fi

echo "[*] Starting stack with interface $IFACE…"
if ! docker compose up -d; then
  echo "[*] Попытка с sudo…"
  sudo docker compose up -d
fi

echo "[*] Done! Suricata теперь слушает $IFACE и HOME_NET = $CIDR"
