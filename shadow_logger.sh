#!/bin/bash
LOG="$HOME/.shadow_logs/$(date +%Y%m%d).log"
mkdir -p "$(dirname "$LOG")"
echo "[$(date '+%H:%M:%S')] [$1] ${*:2}" >> "$LOG"
[ "$1" = "ERROR" ] && echo -e "\033[31m[ERR]\033[0m ${*:2}"
[ "$1" = "OK" ] && echo -e "\033[32m[OK]\033[0m ${*:2}"
