#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}⚠️  Bắt đầu gỡ cài đặt Dọn Dẹp Mac...${NC}"

if [ -d "/Applications/Dọn Dẹp Mac.app" ]; then
    rm -rf "/Applications/Dọn Dẹp Mac.app"
    echo "✓ Đã xoá ứng dụng khỏi /Applications."
fi

read -p "Bạn có muốn xoá cấu hình và API key lưu tại ~/.config/clean_mac không? (y/N): " DEL_CONF
if [[ "$DEL_CONF" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/clean_mac"
    echo "✓ Đã xoá thư mục cấu hình."
fi

echo -e "${GREEN}✓ Đã gỡ cài đặt hoàn tất! Cảm ơn bạn đã sử dụng.${NC}"
