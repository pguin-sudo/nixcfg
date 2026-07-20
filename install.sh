#!/usr/bin/env bash
set -e

NIXCFG_SRC="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${GREEN}=== NixOS Installer — pguin/nixcfg ===${NC}"
echo ""

# Копируем флейк во временную директорию если он read-only (в ISO флейк в /nix/store)
if [[ ! -w "$NIXCFG_SRC" ]]; then
  echo -e "${YELLOW}[*] Флейк read-only, копируем в /tmp/nixcfg...${NC}"
  cp -r "$NIXCFG_SRC" /tmp/nixcfg
  chmod -R u+w /tmp/nixcfg
  NIXCFG=/tmp/nixcfg
else
  NIXCFG="$NIXCFG_SRC"
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

# ── Hostname ──────────────────────────────────────────────────────────────────
echo "Выбери hostname:"
echo "  1) lambda  — ноутбук (ASUS, AMD, nvme0n1)"
echo "  2) delta   — десктоп"
echo ""
read -rp "Hostname [1/2]: " HOST_CHOICE
case "$HOST_CHOICE" in
  1|lambda) HOSTNAME="lambda" ;;
  2|delta)  HOSTNAME="delta"  ;;
  *) echo -e "${RED}Неверный выбор.${NC}"; exit 1 ;;
esac

# ── Диск ──────────────────────────────────────────────────────────────────────
echo ""
echo "Доступные диски:"
lsblk -d -o NAME,SIZE,MODEL | grep -v loop
echo ""

[[ "$HOSTNAME" == "lambda" ]] && DEFAULT_DISK="nvme0n1" || DEFAULT_DISK="sda"

read -rp "Диск для установки [${DEFAULT_DISK}]: " DISK_INPUT
DISK_NAME="${DISK_INPUT:-$DEFAULT_DISK}"
DISK="/dev/$DISK_NAME"

if [[ ! -b "$DISK" ]]; then
  echo -e "${RED}Диск $DISK не найден!${NC}"; exit 1
fi

# ── Определяем режим: свежая установка или продолжение ────────────────────────
MNT_MOUNTED=false
if mountpoint -q /mnt 2>/dev/null; then
  MNT_MOUNTED=true
fi

RESUME=false
if $MNT_MOUNTED; then
  echo -e "${YELLOW}[!] /mnt уже смонтирован. Похоже на прерванную установку.${NC}"
  echo "  r) Продолжить установку (пропустить разметку)"
  echo "  f) Начать заново (стереть диск и разметить)"
  echo ""
  read -rp "Режим [r/f]: " MODE_CHOICE
  case "$MODE_CHOICE" in
    r|resume) RESUME=true ;;
    f|fresh)  RESUME=false ;;
    *) echo -e "${RED}Неверный выбор.${NC}"; exit 1 ;;
  esac
fi

if ! $RESUME; then
  # Если диск отличается от дефолта в partitioning.nix — патчим копию
  DEFAULT_IN_NIX="$(grep 'device = ' "$NIXCFG/hosts/$HOSTNAME/partitioning.nix" 2>/dev/null | head -1 | grep -oP '(?<="/dev/)[^"]+' || true)"
  if [[ -n "$DEFAULT_IN_NIX" && "$DISK_NAME" != "$DEFAULT_IN_NIX" ]]; then
    echo -e "${YELLOW}[*] Обновляем partitioning.nix: /dev/$DEFAULT_IN_NIX → $DISK${NC}"
    sed -i "s|device = \"/dev/$DEFAULT_IN_NIX\"|device = \"$DISK\"|" \
      "$NIXCFG/hosts/$HOSTNAME/partitioning.nix"
  fi

  echo ""
  echo -e "${RED}!!! ВНИМАНИЕ: $DISK будет ПОЛНОСТЬЮ СТЁРТ !!!${NC}"
  echo -e "  Hostname: ${GREEN}$HOSTNAME${NC}  |  Диск: ${GREEN}$DISK${NC}"
  echo ""
  read -rp "Введи 'yes' для продолжения: " CONFIRM
  [[ "$CONFIRM" == "yes" ]] || { echo "Отменено."; exit 0; }

  # ── Disko ───────────────────────────────────────────────────────────────────
  echo ""
  echo -e "${GREEN}[*] Разметка $DISK...${NC}"
  nix run github:nix-community/disko/latest -- \
    --mode disko \
    --flake "$NIXCFG#$HOSTNAME"
else
  # ── Режим продолжения: монтируем то что не смонтировано ─────────────────────
  echo ""
  echo -e "${GREEN}[*] Монтируем разделы...${NC}"

  if ! mountpoint -q /mnt/boot 2>/dev/null; then
    mount /dev/disk/by-partlabel/disk-main-boot /mnt/boot -o fmask=0022,dmask=0022 \
      && echo "  /mnt/boot смонтирован" || echo -e "${YELLOW}  /mnt/boot уже смонтирован или не найден${NC}"
  fi

  if ! swapon --show | grep -q "$(readlink -f /dev/disk/by-partlabel/disk-main-swap 2>/dev/null)"; then
    swapon /dev/disk/by-partlabel/disk-main-swap 2>/dev/null \
      && echo "  swap активирован" || true
  fi
fi

# ── Копируем nixcfg в новую систему ──────────────────────────────────────────
echo ""
echo -e "${GREEN}[*] Копируем nixcfg в /mnt/home/pguin/nixcfg...${NC}"
mkdir -p /mnt/home/pguin
rm -rf /mnt/home/pguin/nixcfg
cp -r "$NIXCFG" /mnt/home/pguin/nixcfg

# ── nixos-install ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}[*] Устанавливаем NixOS ($HOSTNAME)...${NC}"
nixos-install \
  --no-root-passwd \
  --flake "$NIXCFG#$HOSTNAME"

chown -R 1000:1000 /mnt/home/pguin/nixcfg 2>/dev/null || true

echo ""
echo -e "${GREEN}=== Готово! Извлеки флешку и перезагрузись. ===${NC}"
echo ""
echo "После первого входа запусти home-manager:"
echo "  home-manager switch --flake ~/nixcfg#pguin@$HOSTNAME"
