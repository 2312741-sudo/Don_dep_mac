# 🧹 Dọn Dẹp Mac (Mac Cleaner AI)

<p align="center">
  <img src="src/applet.icns" width="128" height="128" alt="Mac Cleaner Icon" />
  <br>
  <b>Ứng dụng tối ưu hoá dung lượng & dọn dẹp hệ thống macOS chuyên sâu tích hợp Gemini 3.6 Flash</b>
  <br>
  <i>Tương thích hoàn hảo với mọi dòng Mac Apple Silicon (M1/M2/M3/M4) và chip Intel</i>
</p>

---

## ⚡ Cài đặt 1 chạm qua Terminal

Chỉ cần mở **Terminal** trên Mac, dán dòng lệnh sau và nhấn **Enter**:

```bash
curl -fsSL https://raw.githubusercontent.com/2312741-sudo/Don_dep_mac/main/install.sh | bash
```

> 💡 **Ưu điểm khi cài qua lệnh Terminal:**
> - Tự động tải và cài đặt vào thư mục `/Applications`.
> - **Tự động mở khóa bảo mật Gatekeeper** (Không bao giờ bị lỗi *"Ứng dụng bị hỏng"* hay *"Apple không thể xác minh"*).
> - Hoàn tất chỉ sau 3-5 giây!

---

## ✨ Điểm nổi bật

* 🤖 **Tư vấn thông minh với AI kép (Hybrid AI)**:
  * Phân tích tình trạng ổ đĩa thời gian thực bằng **Gemini 3.6 Flash**.
  * Tích hợp **Bộ phân tích chuyên gia tại chỗ (Local Smart Engine)**: Nếu người dùng không nhập API key hoặc khi mất mạng, hệ thống vẫn tự động đọc thông số máy và đưa ra đánh giá, mẹo tối ưu chuẩn xác 100%.
* 🖥️ **Giao diện AppKit nguyên bản (Native macOS GUI)**:
  * Thiết kế theo ngôn ngữ Human Interface Guidelines của Apple.
  * Hiển thị bảng điều khiển Console trực tiếp theo thời gian thực (xem chi tiết từng file và mục đang xoá).
  * Thanh tiến trình 9 bước rõ ràng, thông báo dung lượng đã giải phóng khi hoàn tất.
* 📦 **Độc lập hoàn toàn (Standalone)**:
  * Không phụ thuộc vào thư viện bên ngoài.
  * Tự động nhận diện cấu hình môi trường của từng máy.

---

## 🧹 9 Hạng mục rác & cache được xử lý

| Bước | Hạng mục | Tác dụng |
|:---:|:---|:---|
| **1** | **Xcode DerivedData** | Xoá toàn bộ build cache tạm thời của Xcode (thường chiếm từ 10GB - 50GB). |
| **2** | **iOS Simulators & Runtimes** | Xoá sạch các máy ảo và dữ liệu runtime giả lập không còn dùng. |
| **3** | **Gradle Cache & Wrappers** | Dọn dẹp cache tải về của Gradle/Android Studio. |
| **4** | **Homebrew Cleanup** | Gỡ bỏ các phiên bản gói phần mềm cũ và cache cài đặt. |
| **5** | **NPM Cache** | Làm sạch bộ nhớ đệm các gói Node.js (`npm cache clean --force`). |
| **6** | **CocoaPods, Pip, Node-gyp** | Dọn dẹp cache thư viện lập trình iOS và Python. |
| **7** | **AI Agent Caches** | Xoá tệp rác tự sinh từ các AI coding agents (Codex runtimes, Antigravity temp). |
| **8** | **System & User Logs** | Làm sạch các tệp nhật ký lỗi và báo cáo crash cũ (`~/Library/Logs`). |
| **9** | **Thùng rác (Trash)** | Làm rỗng thùng rác an toàn qua AppleScript. |

---

## 🛠️ Tự biên dịch từ mã nguồn (Build from source)

Nếu bạn muốn tự chỉnh sửa mã nguồn và đóng gói:

```bash
git clone https://github.com/2312741-sudo/Don_dep_mac.git
cd Don_dep_mac

# Chạy script build
./scripts/build.sh
```

File ứng dụng `Dọn Dẹp Mac.app` sẽ được tạo trong thư mục `build/` và file nén phát hành trong `release/DonDepMac.zip`.

---

## 🗑️ Gỡ cài đặt (Uninstall)

Nếu không còn nhu cầu sử dụng, bạn có thể chạy lệnh:

```bash
curl -fsSL https://raw.githubusercontent.com/2312741-sudo/Don_dep_mac/main/uninstall.sh | bash
```

Hoặc chỉ đơn giản kéo ứng dụng `Dọn Dẹp Mac` trong thư mục `Applications` vào Thùng rác.

---

<p align="center">
  Được phát triển với tình yêu dành cho cộng đồng người dùng macOS ❤️
</p>
