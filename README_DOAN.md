# BÁO CÁO ĐỒ ÁN CUỐI KỲ: ỨNG DỤNG DANH THIẾP ĐIỆN TỬ
## MÔN HỌC: LẬP TRÌNH TRÊN THIẾT BỊ DI ĐỘNG (MOBILE APPLICATION DEVELOPMENT)
**Nền tảng phát triển:** Flutter Framework (Dart) & Native Hardware APIs  
**Hệ điều hành mục tiêu:** Android & iOS (Hỗ trợ chạy Web & Desktop demo)  

---

## 1. GIỚI THIỆU ĐỀ TÀI & TÍNH CẤP THIẾT
Ứng dụng **Danh Thiếp Điện Tử (Smart Digital Business Card & Contact Wallet)** là giải pháp chuyển đổi số toàn diện nhằm thay thế danh thiếp giấy truyền thống, giải quyết triệt để các hạn chế như: dễ thất lạc, tốn kém chi phí in ấn, thông tin tĩnh không cập nhật được và gây lãng phí tài nguyên môi trường.

Đồ án được thiết kế chuyên sâu cho môn học **Lập trình trên thiết bị di động**, không chỉ dừng lại ở các thao tác CRUD cơ bản mà tập trung mạnh mẽ vào **khai thác phần cứng di động chuyên sâu** (Chip NFC, Camera AI OCR, Định vị GPS) và **tích hợp sâu với hệ điều hành** (Danh bạ gốc Contacts Framework, Xác thực sinh trắc học Biometric, Chia sẻ vCard hệ thống).

---

## 2. KIẾN TRÚC HỆ THỐNG & CẤU TRÚC THƯ MỤC
Dự án được xây dựng theo mô hình phân lớp chuẩn công nghiệp (**Clean Architecture & Provider State Management**):

```
lib/
├── config/
│   ├── app_constants.dart      # Danh mục Template (5 mẫu), Bảng mã màu Theme (7 màu), Tags
│   └── app_theme.dart          # Cấu hình giao diện Material 3 (Light & Dark Theme)
├── models/
│   ├── user_model.dart         # Thông tin tài khoản người dùng
│   ├── business_card_model.dart# Hồ sơ danh thiếp số cá nhân & sinh chuỗi vCard 3.0 chuẩn
│   ├── saved_contact_model.dart# Danh thiếp nhận được trong ví kèm GPS & Context Notes
│   └── analytics_model.dart    # Lượt xem, lưu danh bạ, chạm NFC, quét QR, click-through rate
├── services/
│   ├── database_service.dart   # SQLite cục bộ (sqflite) lưu trữ 100% offline
│   ├── auth_service.dart       # Xác thực Email/Pass, SĐT OTP, Google & Sinh trắc học (local_auth)
│   ├── nfc_service.dart        # Đọc/Ghi thẻ NFC NDEF, giao thức chạm HCE
│   ├── ocr_service.dart        # Trí tuệ nhân tạo Google ML Kit bóc tách chữ từ danh thiếp giấy
│   ├── contact_service.dart    # Giao tiếp Danh bạ gốc (Native Contacts Framework) & vCard parser
│   ├── location_service.dart   # Lấy tọa độ GPS (Geolocator) & giải mã địa chỉ (Geocoding)
│   └── share_service.dart      # Chụp xuất ảnh PNG (Screenshot), tệp .vcf và chia sẻ đa kênh
├── providers/
│   ├── auth_provider.dart      # Quản lý phiên đăng nhập & trạng thái bảo mật vân tay
│   ├── card_provider.dart      # Quản lý danh thiếp cá nhân (Đa hồ sơ - Multi profile)
│   └── wallet_provider.dart    # Quản lý Ví danh thiếp, lọc Tag, tìm kiếm thông minh
├── widgets/
│   ├── business_card_view.dart # Render trực quan 5 Template danh thiếp thời thượng
│   ├── qr_display_dialog.dart  # Modal QR 2 chế độ (QR Tĩnh vCard Offline & QR Động Online)
│   ├── virtual_bg_dialog.dart  # Virtual Background Generator 16:9 cho Zoom/Meet kèm mã QR
│   ├── nfc_sheet.dart          # BottomSheet giao tiếp thẻ NFC & mô phỏng chạm HCE
│   └── ...
└── screens/
    ├── splash_screen.dart      # Màn hình khởi động kiểm tra vân tay / sinh trắc học
    ├── auth/                   # Màn hình Đăng nhập & Đăng ký (Email, Google, Phone OTP)
    ├── home/
    │   ├── main_navigation.dart    # Thanh điều hướng 5 tabs chính
    │   ├── my_cards_screen.dart    # Quản lý Đa hồ sơ & chia sẻ nhanh
    │   ├── card_builder_screen.dart# Trình thiết kế danh thiếp thời gian thực (Live Preview)
    │   ├── card_detail_screen.dart # Chi tiết thẻ, Privacy Toggle, xuất ảnh & phông nền ảo
    │   └── wallet_screen.dart      # Ví danh thiếp nhận được (+ Tọa độ GPS & Ghi chú)
    ├── scan/
    │   ├── scan_hub_screen.dart    # Trung tâm tổng hợp công nghệ phần cứng
    │   ├── qr_scanner_screen.dart  # Quét camera QR code thời gian thực
    │   ├── ocr_scanner_screen.dart # Chụp danh thiếp giấy và bóc tách tự động bằng AI
    │   └── nfc_screen.dart         # Đọc và Ghi thẻ NFC vật lý
    ├── analytics/                  # Biểu đồ phân tích hiệu quả kết nối (fl_chart)
    └── settings/                   # Cài đặt bảo mật vân tay & thông tin đề tài
```

---

## 3. CÁC TÍNH NĂNG ĂN ĐIỂM CHI TIẾT TRONG ĐỒ ÁN

### 🎯 PHẦN 1: HỆ THỐNG TÍNH NĂNG CỐT LÕI (CORE FEATURES)
1. **Xác thực đa phương thức & Bảo mật sinh trắc học (Biometrics):**
   - Đăng nhập/Đăng ký qua Email/Password, Tài khoản Google, Số điện thoại (xác thực mã OTP).
   - Mở khóa sinh trắc học bằng **Vân tay hoặc FaceID** thông qua thư viện `local_auth`.
2. **Đa hồ sơ trên 1 tài khoản (Multi-Profile):**
   - Cho phép người dùng tạo nhiều danh thiếp độc lập tùy ngữ cảnh giao tiếp:
     - *Danh thiếp 1:* Công việc chính thức (Doanh nghiệp, Chức vụ cấp cao).
     - *Danh thiếp 2:* Freelance / Consultant (Dự án ngoài, Portfolio).
     - *Danh thiếp 3:* Cá nhân / Sinh viên.
   - Chuyển đổi linh hoạt và thiết lập danh thiếp mặc định.
3. **Trình thiết kế danh thiếp (Card Builder) với Live Preview:**
   - 5 mẫu thiết kế giao diện độc quyền: **Modern (Hiện đại), Minimalist (Tối giản), Elegant (Sang trọng), Cyber Tech (Công nghệ), Creative (Sáng tạo)**.
   - Bảng mã 7 màu chủ đạo tùy biến theo nhận diện thương hiệu.
   - Nhập thông tin đa dạng: Họ tên, Chức vụ, Công ty, SĐT, Email, Website, Địa chỉ, Bio, Danh sách kỹ năng (Skills tag), Liên kết mạng xã hội (LinkedIn, GitHub, Facebook, Zalo, Twitter, Instagram).
4. **Ví danh thiếp & Quản lý quan hệ (Contact Wallet):**
   - Lưu trữ danh thiếp thu thập được từ người khác.
   - Phân loại bằng Thẻ (Tag): *Khách hàng, Đối tác, Đồng nghiệp, Bạn bè, VIP*.
   - Tìm kiếm thông minh theo từ khóa (tên, SĐT, công ty, địa điểm).
   - **Ghi chú ngữ cảnh (Contextual Notes):** Lưu lại kỷ niệm gặp gỡ, lời nhắc gửi báo giá, hẹn gặp lại.

---

### 🚀 PHẦN 2: TÍCH HỢP PHẦN CỨNG & OS API (TRỌNG TÂM ĂN ĐIỂM)
1. **Camera & Quét mã QR (`mobile_scanner`):**
   - Quét mã QR danh thiếp tốc độ cao, hỗ trợ bật/tắt đèn Flash và đổi camera trước/sau.
   - Nhận diện trực tiếp dữ liệu vCard hoặc URL deep link.
2. **Trí tuệ nhân tạo OCR bóc tách danh thiếp giấy (`google_mlkit_text_recognition`):**
   - Chụp ảnh danh thiếp giấy hoặc chọn ảnh từ bộ sưu tập.
   - Mô hình AI nhận diện ký tự quang học (Latin Text Recognition) kết hợp thuật toán Heuristic & Regex tự động bóc tách chính xác: **Họ tên, SĐT di động, Email, Website, Tên công ty, Chức vụ và Địa chỉ**.
   - Cho phép chỉnh sửa kết quả và lưu thẳng vào ví hoặc nhân bản thành mẫu danh thiếp mới.
3. **Giao tiếp tầm ngắn Chip NFC (`nfc_manager`):**
   - **Đọc thẻ NFC (Read Tag):** Đưa mặt lưng điện thoại lại gần thẻ NFC NDEF để nhận danh thiếp tức thì.
   - **Ghi thẻ NFC (Write Tag):** Ghi toàn bộ dữ liệu danh thiếp số hoặc liên kết profile vào bất kỳ thẻ NFC vật lý nào.
   - **Mô phỏng HCE (Host Card Emulation):** Tính năng giả lập chạm 2 điện thoại truyền dữ liệu phục vụ trình chiếu mượt mà trên máy ảo hoặc thiết bị không có chip NFC.
4. **Đồng bộ Danh bạ gốc của điện thoại (`flutter_contacts`):**
   - Chỉ với **1 nút bấm**, toàn bộ thông tin liên hệ (Tên, Họ, SĐT, Email, Công ty, Chức vụ, Website, Ghi chú) được lưu trực tiếp vào **Danh bạ gốc (Contacts)** của hệ điều hành Android/iOS mà người dùng không cần gõ lại thủ công.
5. **Định vị vị trí gặp gỡ GPS & Geocoding (`geolocator`, `geocoding`):**
   - Khi quét mã QR, chạm NFC hoặc lưu thẻ qua OCR, ứng dụng tự động truy vấn tọa độ GPS độ chính xác cao và giải mã địa chỉ thực tế (ví dụ: *"Quận 1, TP. Hồ Chí Minh • 17/10/2026 18:30"*). Giúp người dùng nhớ chính xác đã gặp đối tác này ở đâu và khi nào.

---

### 🌐 PHẦN 3: HOẠT ĐỘNG NGOẠI TUYẾN & CHIA SẺ ĐA KÊNH (OFFLINE-FIRST)
1. **Hai chế độ mã QR Độc đáo:**
   - **QR Tĩnh (Offline vCard 3.0):** Mã hóa toàn bộ chuỗi chuẩn `BEGIN:VCARD...` trực tiếp vào ma trận QR. Bất kỳ điện thoại nào bật camera thường quét đều tự động nhận diện danh bạ và lưu ngay **kể cả khi không có mạng Internet**!
   - **QR Động (Online URL):** Chứa đường dẫn trang web cá nhân, tự động cập nhật khi bạn thay đổi thông tin trên ứng dụng.
2. **Cơ sở dữ liệu nội bộ SQLite (`sqflite`):**
   - Lưu trữ toàn bộ hồ sơ, danh thiếp đối tác và lịch sử tương tác vào bộ nhớ cục bộ thiết bị. Mở ứng dụng lập tức ngay cả khi mất sóng, trên máy bay.
3. **Chia sẻ đa kênh tiện lợi:**
   - Xuất danh thiếp thành file ảnh PNG độ nét cao (chụp qua `screenshot`).
   - Xuất và gửi file đính kèm `.vcf` qua Zalo, Messenger, AirDrop, Email.

---

### 🌟 PHẦN 4: TÍNH NĂNG NÂNG CAO (ĐIỂM CỘNG XUẤT SẮC)
1. **Bảng điều khiển Thống kê & Phân tích (Analytics Dashboard):**
   - Biểu đồ cột trực quan (`fl_chart`) thống kê số lượt xem danh thiếp theo từng ngày trong tuần.
   - Đo lường tổng lượt xem, số lượt người khác bấm lưu vào danh bạ, số lượt quét QR, số lượt chạm NFC.
   - Thống kê tỷ lệ nhấp (Click-Through Rate - CTR) vào từng mạng xã hội: LinkedIn, Website, SĐT, Email, GitHub.
2. **Trình tạo Phông nền ảo Cuộc họp (Virtual Background Generator):**
   - Tự động sinh hình nền hội nghị trực tuyến tỉ lệ chuẩn 16:9 cho **Zoom / Google Meet / Microsoft Teams**.
   - Phông nền có logo, họ tên, chức danh và góc màn hình đính kèm mã QR để người tham dự cuộc họp quét kết nối trực tiếp từ màn hình máy tính!
3. **Chế độ bảo vệ quyền riêng tư (Privacy Toggle):**
   - Bật/tắt ẩn số điện thoại cá nhân và email trên danh thiếp công khai. Người lạ cần gửi yêu cầu kết nối 2 chiều mới được xem toàn bộ thông tin.

---

## 4. HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG

### Bước 1: Mở thư mục dự án
```bash
cd c:\Code_Flutter\UngDungDanhThiepDienTu
```

### Bước 2: Tải các gói thư viện
```bash
flutter pub get
```

### Bước 3: Chạy ứng dụng trên máy thật Android hoặc máy ảo
```bash
flutter run
```
*(Hoặc nhấn F5 trong VS Code / Android Studio)*

---

## 5. KỊCH BẢN THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN (DEMO SCENARIO)
Khi thuyết trình trước Giảng viên, bạn có thể thực hiện theo kịch bản 5 bước sau để ghi điểm tuyệt đối:

1. **Khởi động & Sinh trắc học:** Mở app, demo đăng nhập bằng Vân tay / FaceID (Biometrics) hoặc OTP qua SĐT.
2. **Quản lý Đa hồ sơ & Thiết kế thẻ:** Cho giảng viên thấy tính năng chuyển đổi qua lại giữa thẻ *"Công việc chính thức"* và *"Freelance Consultant"*. Bấm tạo mới thẻ, đổi Template (Modern, Minimalist, Elegant, Tech) để thấy Live Preview đổi màu và giao diện ngay lập tức.
3. **Chia sẻ Offline vCard & Phông nền ảo:** Bấm nút *"Mã QR Nhanh"*, chuyển sang tab **QR Tĩnh Offline**. Giải thích cho giảng viên: Camera máy thường quét vào sẽ lưu danh bạ ngay không cần Internet hay cài app. Mở tiếp tính năng **Phông nền ảo Zoom 16:9**.
4. **Trọng tâm Phần cứng (Camera OCR, NFC, GPS, Danh bạ gốc):**
   - Vào tab **Quét & Thu thập**: Chụp ảnh danh thiếp giấy để AI Google ML Kit tự động bóc tách Tên, SĐT, Email, Công ty.
   - Chạm thẻ NFC hoặc bấm nút **Mô phỏng NFC (HCE Demo)**.
   - Sau khi lưu, mở màn hình **Ví danh thiếp**: Chỉ ra huy hiệu GPS tọa độ và địa điểm gặp gỡ ("Đã kết nối tại SECC - Quận 7").
   - Nhấn nút **"Lưu Danh Bạ Máy"**: Mở ứng dụng Danh bạ mặc định của điện thoại lên để giảng viên thấy liên hệ đã được lưu thành công vào điện thoại!
5. **Thống kê Analytics:** Mở tab **Thống kê** để trình chiếu biểu đồ tương tác, số lượt click LinkedIn, Website, SĐT.
