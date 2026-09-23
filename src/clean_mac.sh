#!/usr/bin/env bash
# Script dọn dẹp bộ nhớ đệm, simulator, và tệp rác trên macOS
set -e

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/homebrew/bin:$PATH"

INITIAL_AVAIL=$(df -k / | tail -1 | awk '{print $4}')

echo "========================================="
echo "   BẮT ĐẦU DỌN DẸP HỆ THỐNG MAC"
echo "========================================="

# 1. Xcode DerivedData
echo "STEP:1:Dọn dẹp Xcode DerivedData"
echo "-> Đang xoá các file build tạm của Xcode..."
rm -rf "$HOME/Library/Developer/Xcode/DerivedData"/* 2>/dev/null || true
echo "   ✓ Đã dọn dẹp xong Xcode DerivedData."

# 2. Xoá Simulator & Runtimes
echo "STEP:2:Xoá toàn bộ iOS Simulator & Runtimes"
echo "-> Đang xoá các máy ảo và runtime iOS Simulator..."
xcrun simctl erase all 2>/dev/null || true
xcrun simctl delete all 2>/dev/null || true
xcrun simctl runtime delete all 2>/dev/null || true
rm -rf "$HOME/Library/Developer/CoreSimulator/Caches"/* "$HOME/Library/Developer/CoreSimulator/Devices"/* 2>/dev/null || true
echo "   ✓ Đã xoá sạch toàn bộ Simulator & Runtimes."

# 3. Gradle Cache & Wrappers
echo "STEP:3:Dọn dẹp Gradle Cache & Wrappers"
echo "-> Đang dọn dẹp build caches và wrapper cũ của Gradle..."
rm -rf "$HOME/.gradle/caches"/* "$HOME/.gradle/wrapper/dists"/* 2>/dev/null || true
echo "   ✓ Đã giải phóng bộ nhớ đệm Gradle."

# 4. Homebrew Cleanup
echo "STEP:4:Dọn dẹp gói cài đặt cũ của Homebrew"
if command -v brew &>/dev/null; then
    echo "-> Đang chạy brew cleanup..."
    brew cleanup --prune=all -s 2>/dev/null || true
    echo "   ✓ Đã dọn dẹp xong Homebrew."
else
    echo "   (Bỏ qua vì không tìm thấy Homebrew)"
fi

# 5. NPM Cache
echo "STEP:5:Dọn dẹp npm cache"
if command -v npm &>/dev/null; then
    echo "-> Đang làm sạch npm cache..."
    npm cache clean --force 2>/dev/null || true
    echo "   ✓ Đã dọn dẹp xong npm cache."
else
    echo "   (Bỏ qua vì không tìm thấy npm)"
fi

# 6. CocoaPods, Pip, Node-gyp Caches
echo "STEP:6:Dọn dẹp CocoaPods, pip, node-gyp caches"
echo "-> Đang xoá thư mục cache CocoaPods, pip, node-gyp..."
rm -rf "$HOME/Library/Caches/CocoaPods" "$HOME/Library/Caches/pip" "$HOME/Library/Caches/node-gyp" 2>/dev/null || true
echo "   ✓ Đã dọn sạch cache thư viện lập trình."

# 7. AI Agent Caches & Tệp tạm cài đặt
echo "STEP:7:Dọn dẹp tệp rác Agent (Codex/Antigravity)"
echo "-> Đang xoá tệp cài đặt tạm và cache AI Agent..."
rm -rf "$HOME/.cache/codex-runtimes"/codex-runtime-install-* 2>/dev/null || true
rm -rf "$HOME/Library/Caches/com.google.antigravity" "$HOME/Library/Caches/Codex" 2>/dev/null || true
rm -rf "$HOME/.codex/cache" "$HOME/.codex/computer-use" 2>/dev/null || true
echo "   ✓ Đã xoá tệp rác tạm của AI Agent."

# 8. User Logs
echo "STEP:8:Dọn dẹp Logs hệ thống & Báo cáo lỗi"
echo "-> Đang dọn dẹp thư mục ~/Library/Logs..."
rm -rf "$HOME/Library/Logs"/* 2>/dev/null || true
echo "   ✓ Đã làm sạch User Logs."

# 9. Thùng rác (Trash)
echo "STEP:9:Làm sạch Thùng rác (Trash)"
echo "-> Đang làm rỗng Thùng rác..."
osascript -e 'tell application "Finder" to empty trash' 2>/dev/null || true
echo "   ✓ Đã dọn sạch Thùng rác."

FINAL_AVAIL=$(df -k / | tail -1 | awk '{print $4}')
DIFF_KB=$(( FINAL_AVAIL - INITIAL_AVAIL ))

if [ $DIFF_KB -gt 1048576 ]; then
    DIFF_STR="$(echo "scale=2; $DIFF_KB / 1048576" | bc) GB"
elif [ $DIFF_KB -gt 1024 ]; then
    DIFF_STR="$(echo "scale=2; $DIFF_KB / 1024" | bc) MB"
elif [ $DIFF_KB -gt 0 ]; then
    DIFF_STR="${DIFF_KB} KB"
else
    DIFF_STR="0 MB (Đĩa đã sạch sẵn)"
fi

FINAL_READABLE=$(df -h / | tail -1 | awk '{print $4}')

echo "FINISH:${DIFF_STR}:${FINAL_READABLE}"
echo "========================================="
echo "   HOÀN TẤT DỌN DẸP!"
echo "   Đã giải phóng: $DIFF_STR"
echo "   Dung lượng khả dụng hiện tại: $FINAL_READABLE"
echo "========================================="
