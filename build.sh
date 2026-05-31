#!/bin/bash
set -e

PROJ_DIR=~/AntiDarkSword
GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}[1/4] Удаляем старые .deb и .ipa...${NC}"
find "$PROJ_DIR" -name "*.deb" -delete
find "$PROJ_DIR" -name "*.ipa" -delete
echo -e "${GREEN}    Готово${NC}"

echo -e "${CYAN}[2/4] Запускаем сборку Theos...${NC}"
cd "$PROJ_DIR"
make package FINALPACKAGE=1 2>&1

echo -e "${CYAN}[3/4] Ищем собранный .deb...${NC}"
DEB=$(find "$PROJ_DIR/packages" -name "*.deb" | sort | tail -1)
if [ -z "$DEB" ]; then
    echo -e "${RED}❌ .deb не найден!${NC}"; exit 1
fi
echo -e "${GREEN}    Найден: $DEB${NC}"

echo -e "${CYAN}[4/4] Конвертируем .deb → DarkSword.ipa...${NC}"
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

ar x "$DEB"

echo "    Содержимое deb:"
ls -la "$TMPDIR"

# Автоматически находим data.tar.* любого расширения
DATA=$(ls data.tar.* 2>/dev/null | head -1)
if [ -z "$DATA" ]; then
    echo -e "${RED}❌ data.tar.* не найден. Файлы: $(ls)${NC}"
    rm -rf "$TMPDIR"; exit 1
fi
echo -e "${GREEN}    Распаковываем: $DATA${NC}"

case "$DATA" in
    *.gz)   tar xzf "$DATA" ;;
    *.xz)   tar xJf "$DATA" ;;
    *.zst)  zstd -d "$DATA" --stdout | tar x ;;
    *.lz4)  lz4 -d "$DATA" --stdout | tar x ;;
    *.bz2)  tar xjf "$DATA" ;;
    *)      tar xf "$DATA" ;;
esac

APP=$(find . -name "*.app" -maxdepth 8 | head -1)
if [ -z "$APP" ]; then
    echo -e "${RED}❌ .app не найден внутри .deb${NC}"
    rm -rf "$TMPDIR"; exit 1
fi
echo -e "${GREEN}    .app найден: $APP${NC}"

mkdir -p Payload
cp -r "$APP" Payload/
zip -qr DarkSword.zip Payload/
mv DarkSword.zip "$PROJ_DIR/DarkSword.ipa"

rm -rf "$TMPDIR"
echo -e "${GREEN}✅ Готово! → $PROJ_DIR/DarkSword.ipa${NC}"
