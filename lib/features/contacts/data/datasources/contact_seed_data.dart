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
        notes: 'Gặp gỡ trao đổi về dự án giải pháp thanh toán số tại Vietnam Tech Summit 2026.',
        savedAt: now.subtract(const Duration(days: 5)),
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
        tags: const ['Đối tác'],
        notes: 'Đối tác tư vấn kiến trúc Flutter đa nền tảng và CI/CD.',
        savedAt: now.subtract(const Duration(days: 12)),
      ),
      SavedContact(
        id: 'contact_03',
        ownerId: ownerId,
        originalCardId: 'card_demo_nam',
        fullName: 'Lê Hoàng Nam',
        jobTitle: 'UI/UX Design Specialist',
        company: 'Creative Studio Freelance',
        phone: '0938765432',
        email: 'nam.design@gmail.com',
        website: 'https://namdesign.portfolio.io',
        address: 'Quận 3, TP. Hồ Chí Minh',
        tags: const ['Đồng nghiệp', 'Hội thảo'],
        notes: 'Chuyên gia thiết kế hệ thống Design System Material 3.',
        savedAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }
}
