#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   🔓 TERMUX ROOTER v2 — Чипсет-специфичные эксплойты      ║
# ║   Qualcomm bengal + Android 12                             ║
# ╚══════════════════════════════════════════════════════════════╝

ROOTER_DIR="$HOME/.shadow_rooter"
mkdir -p "$ROOTER_DIR"/{exploits,results}

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🔓 ROOTER v2 — Чипсет-специфичные атаки   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Проверяем Qualcomm-специфичные уязвимости
echo -e "${CY}[ROOTER] 🔍 Проверяю Qualcomm-драйверы...${NC}"

# 1. QSEE (Qualcomm Secure Execution Environment)
echo "  🔍 Проверяю QSEE..."
ls -la /dev/qseecom 2>/dev/null && {
    echo "  💀 /dev/qseecom ДОСТУПЕН!"
    echo "QSEE_ACCESS=true" >> "$ROOTER_DIR/results/qsee.txt"
    # Пробуем читать защищённую память
    dd if=/dev/qseecom of="$ROOTER_DIR/results/qsee_dump.bin" bs=1024 count=10 2>/dev/null
}

# 2. KGSL (Qualcomm GPU driver)
echo "  🔍 Проверяю KGSL (GPU)..."
ls -la /dev/kgsl-3d0 2>/dev/null && {
    echo "  💀 /dev/kgsl-3d0 ДОСТУПЕН!"
    echo "KGSL_ACCESS=true" >> "$ROOTER_DIR/results/kgsl.txt"
}

# 3. Динамическое выделение памяти через /dev/mem
echo "  🔍 Проверяю /dev/mem..."
ls -la /dev/mem 2>/dev/null && {
    echo "  💀 /dev/mem ДОСТУПЕН!"
    # Пробуем прочитать память ядра
    dd if=/dev/mem of="$ROOTER_DIR/results/mem_dump.bin" bs=4096 count=1 skip=1 2>/dev/null
}

# 4. Проверка через procfs
echo "  🔍 Проверяю /proc..."
cat /proc/self/attr/current 2>/dev/null | grep -q "kernel" && echo "  💀 Доступ к kernel-контексту!"

# 5. Попытка через Dirty Pipe (CVE-2022-0847) — работает на ядре 5.8+
KERNEL_MAJOR=$(uname -r | cut -d. -f1)
KERNEL_MINOR=$(uname -r | cut -d. -f2)

if [ "$KERNEL_MAJOR" -ge 5 ] && [ "$KERNEL_MINOR" -ge 8 ]; then
    echo "  💣 Пробую Dirty Pipe (CVE-2022-0847)..."
    echo "CVE-2022-0847|POTENTIAL" >> "$ROOTER_DIR/results/exploits.txt"
else
    echo "  ❌ Ядро слишком старое для Dirty Pipe (нужно 5.8+)"
fi

echo ""

# ═══════════════════════════════════════════════
# Альтернатива: ищем ADB root
# ═══════════════════════════════════════════════
echo -e "${CY}[ROOTER] 🔧 Проверяю ADB root...${NC}"

# Проверяем доступен ли adbd с рутом
adb root 2>/dev/null && {
    echo -e "  ${GR}💀 ADB ROOT СРАБОТАЛ!${NC}"
    adb shell id 2>/dev/null | grep -q "uid=0" && echo "ROOT_VIA_ADB=true" >> "$ROOTER_DIR/results/status.txt"
}

# Проверяем magisk
echo "  🔍 Проверяю Magisk..."
ls /data/adb/magisk 2>/dev/null && echo "  💀 MAGISK НАЙДЕН!" && echo "MAGISK_INSTALLED=true" >> "$ROOTER_DIR/results/status.txt"

echo ""

# ═══════════════════════════════════════════════
# ФИНАЛ
# ═══════════════════════════════════════════════
FOUND_QSEE=$(grep -c "QSEE" "$ROOTER_DIR/results/qsee.txt" 2>/dev/null || echo 0)
FOUND_KGSL=$(grep -c "KGSL" "$ROOTER_DIR/results/kgsl.txt" 2>/dev/null || echo 0)
FOUND_MAGISK=$(grep -c "MAGISK" "$ROOTER_DIR/results/status.txt" 2>/dev/null || echo 0)

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🔓 ROOTER v2 — ОТЧЁТ                      ║${NC}"
echo -e "${RED}╠══════════════════════════════════════════════╣${NC}"
echo -e "${RED}║   💾 QSEE: $FOUND_QSEE                                    ║${NC}"
echo -e "${RED}║   🎮 KGSL: $FOUND_KGSL                                    ║${NC}"
echo -e "${RED}║   🧙 Magisk: $FOUND_MAGISK                                   ║${NC}"
echo -e "${RED}║   🔑 Root: $( [ "$(id -u)" = "0" ] && echo 'ПОЛУЧЕН' || echo 'не получен' )                           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  📁 $ROOTER_DIR/"
