# Phân hệ Thiết kế & Quản lý Danh thiếp (Thành viên 2)

## 1. Giới thiệu tổng quan
Phân hệ này đảm nhận toàn bộ nghiệp vụ tạo, tùy biến, lưu trữ và quản lý đa danh thiếp (Multi-Profile) của người dùng trong ứng dụng Danh thiếp Điện tử.

## 2. Kiến trúc & Công nghệ
- **Mô hình kiến trúc:** Feature-First (Domain - Data - Presentation)
- **Quản lý trạng thái (State Management):** `flutter_riverpod`
- **Điều hướng (Routing):** `go_router` + hỗ trợ fallback `Navigator`
- **Pattern Repository:** Hỗ trợ chuyển đổi tức thì giữa môi trường chạy Offline (`FakeCardRepository` / `FakeStorageRepository`) và Cloud (`FirebaseCardRepository` / `FirebaseStorageRepository`) thông qua cờ `useMockDataProvider`.
- **Thiết kế & Giao diện:** Material 3, hỗ trợ Dark / Light mode, Responsive layout (ghim Live Preview 2 cột trên Tablet / Web và ghim phía trên màn hình Mobile).

## 3. Cấu trúc thư mục
```
lib/
  core/
    constants/card_constants.dart    # 8 Google Fonts tiếng Việt, bảng màu gợi ý M3, giới hạn 5 thẻ
    theme/app_theme.dart             # Material 3 light/dark theme
    utils/
      result.dart                    # Result pattern (Success/Failure)
      wcag_contrast.dart             # Tính toán độ sáng tương đối & tương phản WCAG 2.1 (AA / AAA)
    validators/card_validators.dart  # Kiểm tra email, SĐT Việt Nam, URL, độ dài bio
    widgets/                         # Shimmer, SnackBar, ConfirmDialog
    router/app_router.dart           # Cấu hình GoRouter (/ và /editor)
  features/card_design/
    domain/
      entities/
        business_card.dart           # Entity danh thiếp đa hồ sơ
        card_design.dart             # Entity cấu hình giao diện (màu, font, bo góc, banner)
        social_link.dart             # Entity liên kết mạng xã hội
      repositories/
        card_repository.dart         # Interface CRUD danh thiếp
        storage_repository.dart      # Interface tải ảnh lên Storage
    data/
      datasources/card_seed_data.dart# Dữ liệu khởi tạo mặc định (Mai Văn Tâm)
      models/                        # Serializer / Deserializer Firestore & JSON
      repositories/
        fake_card_repository.dart    # InMemory repository cho môi trường test/offline
        fake_storage_repository.dart # Local file storage mô phỏng
        firebase_card_repository.dart# Firestore repository thật
        firebase_storage_repository.dart # Cloud Storage repository thật (nén ảnh < 1MB)
    presentation/
      providers/                     # Riverpod controllers & streams
      widgets/
        templates/                   # TemplateRegistry & 4 templates (Modern, Classic, Minimal, Creative)
        sheets/                      # ColorPickerSheet (WCAG), FontPickerSheet, SocialLinkEditorSheet
        editor_tabs/                 # CardInfoTab, CardDesignTab, CardSocialsTab (Reorderable)
        card_preview.dart            # Live Preview component
        image_upload_field.dart      # Chọn ảnh, cắt cropper 1:1 và 16:9
      screens/
        my_cards_screen.dart         # Màn hình danh sách thẻ của tôi
        card_editor_screen.dart      # Trình tạo/sửa thẻ với Live Preview thời gian thực
```

## 4. Các tính năng nổi bật
1. **Đa hồ sơ (Multi-profile):** Tạo tối đa 5 thẻ độc lập (Thẻ công việc, Thẻ freelance...), đánh dấu thẻ Mặc định, Nhân bản nhanh thẻ.
2. **Live Preview theo thời gian thực:** Mọi thay đổi về thông tin cá nhân, ảnh đại diện, ảnh bìa, màu sắc, font chữ và liên kết đều phản chiếu tức thì trên widget thẻ trước khi bấm Lưu.
3. **Template Registry:** 4 mẫu giao diện linh hoạt:
   - *Hiện Đại (Modern)*: Banner lớn, avatar nổi.
   - *Cổ Điển (Classic)*: Doanh nghiệp chỉn chu.
   - *Tối Giản (Minimal)*: Chú trọng kiểu chữ và khoảng trắng.
   - *Sáng Tạo (Creative)*: Gradient rực rỡ và hiệu ứng mờ nghệ thuật.
4. **Bộ chọn màu & Cảnh báo WCAG:** Tự động tính toán tỉ lệ tương phản chữ/nền theo chuẩn WCAG 2.1; cảnh báo người dùng khi độ tương phản không đạt chuẩn AA (4.5:1).
5. **8 Phông chữ Google Fonts tiếng Việt:** Hỗ trợ Roboto, Montserrat, Open Sans, Inter, Poppins, Playfair Display, Merriweather, Oswald.
6. **Kéo thả sắp xếp Social Links (Reorderable):** Tùy ý thay đổi vị trí, bật/tắt hiển thị, tự động chuẩn hóa URL/SĐT và nút "Thử mở liên kết" trước khi lưu.
7. **Cắt và nén ảnh (Cropper & Compress):** Cắt ảnh đại diện 1:1, ảnh bìa 16:9, tự động nén tối ưu dưới 1MB trước khi đưa lên Cloud Storage.
