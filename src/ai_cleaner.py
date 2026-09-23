#!/usr/bin/env python3
import os
import sys
import json
import time
import shutil
import subprocess
import urllib.request
import urllib.error
from pathlib import Path

CONFIG_DIR = Path.home() / ".config" / "clean_mac"
USER_KEY_FILE = CONFIG_DIR / "gemini_api_key"
BUNDLE_KEY_FILE = Path(__file__).resolve().parent / "gemini_api_key"

def get_api_key():
    env_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if env_key:
        return env_key
    if USER_KEY_FILE.exists():
        key = USER_KEY_FILE.read_text().strip()
        if key:
            return key
    if BUNDLE_KEY_FILE.exists():
        key = BUNDLE_KEY_FILE.read_text().strip()
        if key:
            return key
    return None

def get_dir_size_str(path):
    p = Path(path).expanduser()
    if not p.exists():
        return "0 B"
    try:
        res = subprocess.run(["du", "-sh", str(p)], capture_output=True, text=True, timeout=5)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip().split()[0]
    except Exception:
        pass
    return "0 B"

def scan_system():
    scan_data = {}
    total, used, free = shutil.disk_usage("/")
    scan_data["disk_total_gb"] = round(total / (1024**3), 1)
    scan_data["disk_used_gb"] = round(used / (1024**3), 1)
    scan_data["disk_free_gb"] = round(free / (1024**3), 1)
    
    scan_data["xcode_derived_data"] = get_dir_size_str("~/Library/Developer/Xcode/DerivedData")
    scan_data["gradle_cache"] = get_dir_size_str("~/.gradle")
    scan_data["homebrew_cache"] = get_dir_size_str("~/Library/Caches/Homebrew")
    scan_data["npm_cache"] = get_dir_size_str("~/.npm")
    scan_data["agent_cache"] = get_dir_size_str("~/.cache/codex-runtimes")
    scan_data["user_logs"] = get_dir_size_str("~/Library/Logs")
    
    try:
        res = subprocess.run(["xcrun", "simctl", "list", "devices"], capture_output=True, text=True)
        dev_count = len([line for line in res.stdout.splitlines() if "(Shutdown)" in line or "(Booted)" in line])
        scan_data["simulator_devices_count"] = dev_count
    except Exception:
        scan_data["simulator_devices_count"] = 0
        
    return scan_data

def generate_local_expert_advice(scan_data):
    free_gb = scan_data.get('disk_free_gb', 0)
    total_gb = scan_data.get('disk_total_gb', 1)
    used_gb = scan_data.get('disk_used_gb', 0)
    free_pct = round((free_gb / total_gb) * 100, 1)
    
    # 1. Tình trạng ổ đĩa
    if free_pct >= 40:
        disk_status = f"Ổ đĩa rất thoáng (còn trống {free_gb} GB ~ {free_pct}%). Hệ thống có không gian bộ nhớ ảo dồi dào để chạy mượt mà."
    elif free_pct >= 20:
        disk_status = f"Ổ đĩa ở mức ổn định (trống {free_gb} GB ~ {free_pct}%). Dọn dẹp định kỳ để tránh chạm ngưỡng đầy ổ cứng."
    else:
        disk_status = f"Cảnh báo: Ổ đĩa đang gần đầy (chỉ còn {free_gb} GB ~ {free_pct}%). Cần giải phóng các cache thừa để tránh hiện tượng giật lag."
        
    # 2. Phân tích rác
    details = []
    if scan_data.get('xcode_derived_data') not in ['0 B', '']:
        details.append(f"Xcode DerivedData ({scan_data['xcode_derived_data']})")
    if scan_data.get('gradle_cache') not in ['0 B', '']:
        details.append(f"Gradle Cache ({scan_data['gradle_cache']})")
    if scan_data.get('homebrew_cache') not in ['0 B', '']:
        details.append(f"Homebrew Cache ({scan_data['homebrew_cache']})")
    if scan_data.get('npm_cache') not in ['0 B', '']:
        details.append(f"NPM Cache ({scan_data['npm_cache']})")
    if scan_data.get('agent_cache') not in ['0 B', '']:
        details.append(f"Agent Cache ({scan_data['agent_cache']})")
    sim_count = scan_data.get('simulator_devices_count', 0)
    if sim_count > 0:
        details.append(f"{sim_count} máy ảo Simulator")
        
    if details:
        benefit = f"Thu hồi bộ nhớ từ: {', '.join(details)}. Giúp giải phóng SSD và tăng tốc độ biên dịch ứng dụng."
    else:
        benefit = "Làm sạch bộ nhớ đệm lập trình, các file tạm và dọn nhật ký log hệ thống cũ."

    advice = "Khuyến nghị: Hãy khởi động lại máy 1 lần/tuần để macOS tự tối ưu RAM và duy trì tốc độ tốt nhất."
    
    return f"""• Tình trạng: {disk_status}
• Lợi ích dọn dẹp: {benefit}
• Mẹo duy trì: {advice}"""

def consult_gemini(api_key, scan_data):
    models = ["gemini-3.6-flash", "gemini-3.5-flash-lite"]
    prompt = f"""
Bạn là chuyên gia kỹ thuật Apple và bảo trì hệ thống macOS.
Thông số hệ thống trước khi dọn dẹp:
- Ổ cứng: Tổng {scan_data['disk_total_gb']} GB, Đã dùng {scan_data['disk_used_gb']} GB, Khả dụng {scan_data['disk_free_gb']} GB.
- Xcode DerivedData: {scan_data['xcode_derived_data']}
- Gradle Cache: {scan_data['gradle_cache']}
- Homebrew Cache: {scan_data['homebrew_cache']}
- NPM Cache: {scan_data['npm_cache']}
- Caches AI Agent & Codex temp: {scan_data['agent_cache']}
- Logs hệ thống: {scan_data['user_logs']}
- Số lượng iOS Simulator ảo: {scan_data['simulator_devices_count']} máy

Viết nhận xét cực kỳ ngắn gọn (3-4 dòng gạch đầu dòng bằng tiếng Việt):
- Tình trạng ổ đĩa hiện tại (rất thoáng hay đang đầy).
- Lợi ích của việc dọn dẹp các mục rác/cache trên.
- Một câu ngắn động viên hoặc mẹo nhỏ duy trì máy chạy mượt.
"""
    payload = {"contents": [{"parts": [{"text": prompt}]}]}
    for model in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        try:
            with urllib.request.urlopen(req, timeout=8) as response:
                result = json.loads(response.read().decode("utf-8"))
                candidate = result.get("candidates", [{}])[0]
                content = candidate.get("content", {}).get("parts", [{}])[0].get("text", "")
                if content:
                    return content.strip()
        except Exception:
            continue
    # Nếu API lỗi hoặc quá tải -> kích hoạt AI chuyên gia nội bộ
    return generate_local_expert_advice(scan_data)

def main():
    api_key = get_api_key()
    scan_data = scan_system()
    
    if "--analyze-only" in sys.argv:
        if api_key:
            advice = consult_gemini(api_key, scan_data)
        else:
            advice = generate_local_expert_advice(scan_data)
        print(advice)
        sys.exit(0)

    # Chế độ chạy thông thường (CLI hoặc Terminal)
    if api_key:
        print("🤖 [AI]: Đang phân tích tình trạng máy tính...")
        ai_advice = consult_gemini(api_key, scan_data)
    else:
        ai_advice = generate_local_expert_advice(scan_data)

    print("\n🤖 [AI PHÂN TÍCH & TƯ VẤN]:")
    print(ai_advice)
    print("\n-----------------------------------------")
    print("🧹 [BẮT ĐẦU QUY TRÌNH DỌN DẸP CHI TIẾT]:\n")
    sys.stdout.flush()

    bundle_script = Path(__file__).resolve().parent / "clean_mac.sh"
    script_path = bundle_script if bundle_script.exists() else (Path.home() / ".local" / "bin" / "clean_mac.sh")
    
    proc = subprocess.Popen([str(script_path)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
    for line in proc.stdout:
        print(line, end="", flush=True)
    proc.wait()

if __name__ == "__main__":
    main()
