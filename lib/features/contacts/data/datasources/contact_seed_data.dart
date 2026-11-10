import '../../domain/entities/saved_contact.dart';

class ContactSeedData {
  static List<SavedContact> getInitialContacts(String ownerId) {
    final now = DateTime.now();

    return [
      SavedContact(
        id: 'contact_01',
        ownerId: ownerId,
        originalCardId: 'card_demo_lan',
        fullName: 'Nguyễn Thị Lan',
        jobTitle: 'Giám đốc Sản phẩm (Product Director)',
        company: 'Tập đoàn Công nghệ VinTech',
        phone: '0912345678',
        email: 'lan.nguyen@vintech.com.vn',
        website: 'https://vintech.com.vn',
        address: 'Quận Cầu Giấy, Hà Nội',
        tags: const ['Khách hàng', 'VIP'],
        notes: 'Khách hàng tiềm năng: Đang thảo luận gói tích hợp giải pháp thanh toán số và danh thiếp NFC cho 500 nhân sự VinTech. Cần gửi báo giá trước thứ Sáu.',
        source: 'Quét mã QR',
        savedLocation: 'Trung tâm Hội nghị Quốc gia, Hà Nội',
        savedAt: now.subtract(const Duration(days: 2)),
      ),
      SavedContact(
        id: 'contact_02',
        ownerId: ownerId,
        originalCardId: 'card_demo_minh',
        fullName: 'Trần Quang Minh',
        jobTitle: 'Trưởng nhóm Mobile (Mobile Lead)',
        company: 'FPT Software Global',
        phone: '0903456789',
        email: 'minhtq@fsoft.com.vn',
        website: 'https://fpt-software.com',
        address: 'Khu Công nghệ cao, TP. Thủ Đức, TP. HCM',
        tags: const ['Đồng nghiệp', 'Đối tác'],
        notes: 'Đồng nghiệp cũ cùng phát triển thư viện Flutter. Trao đổi về kiến trúc Clean Architecture & State Management Riverpod.',
        source: 'Chạm thẻ NFC',
        savedLocation: 'Khu Công nghệ cao, TP. Thủ Đức',
        savedAt: now.subtract(const Duration(days: 5)),
      ),
      SavedContact(
        id: 'contact_03',
        ownerId: ownerId,
        originalCardId: 'card_demo_nam',
        fullName: 'Lê Hoàng Nam',
        jobTitle: 'Senior UI/UX Designer',
        company: 'Creative Studio Freelance',
        phone: '0938765432',
        email: 'nam.design@gmail.com',
        website: 'https://namdesign.portfolio.io',
        address: 'Quận 3, TP. Hồ Chí Minh',
        tags: const ['Sự kiện', 'Đồng nghiệp'],
        notes: 'Gặp gỡ tại Sự kiện Vietnam Tech Expo 2026. Có thể hợp tác thiết kế các template danh thiếp phong cách Cyber Tech và Minimalist.',
        source: 'Quét mã QR',
        savedLocation: 'SECC, Quận 7, TP. HCM',
        savedAt: now.subtract(const Duration(days: 9)),
      ),
    ];
  }
}
