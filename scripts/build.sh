#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
BUILD_DIR="$DIR/build"
APP_NAME="Dọn Dẹp Mac.app"
APP_PATH="$BUILD_DIR/$APP_NAME"
RELEASE_DIR="$DIR/release"

echo "🔨 Bắt đầu build ứng dụng $APP_NAME..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

echo "-> Biên dịch mã nguồn Swift..."
swiftc "$DIR/src/CleanerApp.swift" -o "$APP_PATH/Contents/MacOS/applet"
chmod +x "$APP_PATH/Contents/MacOS/applet"

echo "-> Sao chép tài nguyên & scripts..."
cp "$DIR/src/Info.plist" "$APP_PATH/Contents/Info.plist"
cp "$DIR/src/applet.icns" "$APP_PATH/Contents/Resources/applet.icns"
cp "$DIR/src/clean_mac.sh" "$APP_PATH/Contents/Resources/clean_mac.sh"
cp "$DIR/src/ai_cleaner.py" "$APP_PATH/Contents/Resources/ai_cleaner.py"
chmod +x "$APP_PATH/Contents/Resources/clean_mac.sh"
chmod +x "$APP_PATH/Contents/Resources/ai_cleaner.py"


echo "-> Thiết lập Icon & Ký mã (Code Signing)..."
xattr -cr "$APP_PATH"
codesign -s - -f "$APP_PATH"

echo "-> Đóng gói thành file zip phát hành..."
ZIP_PATH="$RELEASE_DIR/DonDepMac.zip"
rm -f "$ZIP_PATH"
cd "$BUILD_DIR"
ditto -c -k --sequesterRsrc --keepParent "$APP_NAME" "$ZIP_PATH"

echo "✓ Build hoàn tất thành công!"
echo "📦 File zip phát hành: $ZIP_PATH ($(du -sh "$ZIP_PATH" | awk '{print $1}'))"
