#!/usr/bin/env bash
set -e

# Màu sắc hiển thị
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "=================================================="
echo "    🚀 CÀI ĐẶT ỨNG DỤNG DỌN DẸP MAC (AI CLEANER) "
echo "=================================================="
echo -e "${NC}"

TEMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

ZIP_URL="https://raw.githubusercontent.com/2312741-sudo/Don_dep_mac/main/release/DonDepMac.zip"

echo -e "${BLUE}-> Đang tải gói cài đặt từ GitHub...${NC}"
curl -fsSL "$ZIP_URL" -o "$TEMP_DIR/DonDepMac.zip"

echo -e "${BLUE}-> Đang cài đặt vào thư mục /Applications...${NC}"
rm -rf "/Applications/Dọn Dẹp Mac.app"
ditto -x -k "$TEMP_DIR/DonDepMac.zip" /Applications/

echo -e "${BLUE}-> Mở khoá bảo mật macOS Gatekeeper...${NC}"
xattr -cr "/Applications/Dọn Dẹp Mac.app" 2>/dev/null || true
codesign -s - -f "/Applications/Dọn Dẹp Mac.app" 2>/dev/null || true

# Cấu hình API Key (tuỳ chọn)
mkdir -p "$HOME/.config/clean_mac"
KEY_FILE="$HOME/.config/clean_mac/gemini_api_key"

echo ""
echo -e "${YELLOW}🤖 CẤU HÌNH AI TƯ VẤN (GEMINI 3.6 FLASH):${NC}"
echo "Ứng dụng đã tích hợp sẵn AI mặc định. Nếu bạn có Google Gemini API Key riêng,"
read -p "👉 Hãy nhập Key của bạn (hoặc nhấn ENTER để dùng AI mặc định có sẵn): " USER_KEY

if [ -n "$USER_KEY" ]; then
    echo "$USER_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo -e "${GREEN}✓ Đã lưu API Key riêng của bạn thành công!${NC}"
else
    echo -e "${GREEN}✓ Sử dụng AI tích hợp mặc định của ứng dụng.${NC}"
fi

echo ""
echo -e "${GREEN}=================================================="
echo "    🎉 CÀI ĐẶT THÀNH CÔNG RỰC RỠ!"
echo "==================================================${NC}"
echo "👉 Bạn có thể tìm thấy 'Dọn Dẹp Mac' trong Launchpad hoặc thư mục Applications."
echo ""

read -p "🚀 Bạn có muốn mở ứng dụng ngay bây giờ không? (y/N): " OPEN_NOW
if [[ "$OPEN_NOW" =~ ^[Yy]$ ]]; then
    open "/Applications/Dọn Dẹp Mac.app"
fi
