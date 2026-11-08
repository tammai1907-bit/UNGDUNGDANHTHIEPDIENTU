import '../../domain/entities/business_card.dart';
import '../../domain/entities/card_design.dart';
import '../../domain/entities/social_link.dart';

/// Dữ liệu mẫu khởi tạo cho người dùng Mai Văn Tâm khi chạy chế độ InMemory/Mock
class CardSeedData {
  static List<BusinessCard> getInitialCards(String ownerId) {
    final now = DateTime.now();

    return [
      // Thẻ 1: Công việc chính thức
      BusinessCard(
        id: 'card_official_tam',
        ownerId: ownerId,
        cardName: 'Công Việc Chính Thức',
        fullName: 'Mai Văn Tâm',
        jobTitle: 'Kỹ sư Phần mềm Cấp cao (Senior Mobile Engineer)',
        company: 'Tập đoàn Công nghệ TechCorp VN',
        bio: 'Chuyên gia phát triển ứng dụng di động Flutter & iOS Native với hơn 5 năm kinh nghiệm thực chiến.',
        phone: '0987654321',
        email: 'tam.mai@techcorp.vn',
        website: 'https://techcorp.vn',
        address: 'Tầng 12, Tòa nhà Innovation, Quận 1, TP. Hồ Chí Minh',
        avatarUrl: null, // Sẽ hiển thị Avatar chữ cái hoặc placeholder
        bannerUrl: null,
        design: CardDesign.fromHex(
          templateId: 'modern',
          primaryColorHex: '#1565C0',
          secondaryColorHex: '#0D47A1',
          backgroundColorHex: '#FFFFFF',
          textColorHex: '#1A202C',
          fontFamily: 'Roboto',
          cornerRadius: 16.0,
          showBanner: true,
        ),
        socialLinks: [
          SocialLink(
            id: 'link_phone_1',
            type: SocialLinkType.phone,
            value: '0987654321',
            label: 'Gọi điện',
            order: 0,
            isVisible: true,
          ),
          SocialLink(
            id: 'link_email_1',
            type: SocialLinkType.email,
            value: 'tam.mai@techcorp.vn',
            label: 'Email',
            order: 1,
            isVisible: true,
          ),
          SocialLink(
            id: 'link_linkedin_1',
            type: SocialLinkType.linkedin,
            value: 'https://linkedin.com/in/maivantam-dev',
            label: 'LinkedIn',
            order: 2,
            isVisible: true,
          ),
          SocialLink(
            id: 'link_github_1',
            type: SocialLinkType.github,
            value: 'https://github.com/maivantam',
            label: 'GitHub',
            order: 3,
            isVisible: true,
          ),
          SocialLink(
            id: 'link_zalo_1',
            type: SocialLinkType.zalo,
            value: 'https://zalo.me/0987654321',
            label: 'Zalo',
            order: 4,
            isVisible: true,
          ),
        ],
        isDefault: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),

      // Thẻ 2: Dự án Freelance & Tư Vấn
      BusinessCard(
        id: 'card_freelance_tam',
        ownerId: ownerId,
        cardName: 'Dự Án Freelance & Tư Vấn',
        fullName: 'Tâm Mai (Kevin)',
        jobTitle: 'Full-stack Mobile & UI/UX Consultant',
        company: 'Mai Digital Studio',
        bio: 'Tư vấn kiến trúc hệ thống và xây dựng ứng dụng di động chuẩn UI/UX quốc tế.',
        phone: '0912345678',
        email: 'contact@maivantam.dev',
        website: 'https://maivantam.dev',
        address: 'Quận Bình Thạnh, TP. Hồ Chí Minh',
        avatarUrl: null,
        bannerUrl: null,
        design: CardDesign.fromHex(
          templateId: 'creative',
          primaryColorHex: '#6A1B9A',
          secondaryColorHex: '#8E24AA',
          backgroundColorHex: '#FDFBFE',
          textColorHex: '#212121',
          fontFamily: 'Montserrat',
          cornerRadius: 20.0,
          showBanner: true,
        ),
        socialLinks: [
          SocialLink(
            id: 'link_github_2',
            type: SocialLinkType.github,
            value: 'https://github.com/maivantam',
            label: 'GitHub',
            order: 0,
            isVisible: true,
          ),
          SocialLink(
            id: 'link_linkedin_2',
            type: SocialLinkType.linkedin,
            value: 'https://linkedin.com/in/maivantam-dev',
            label: 'LinkedIn',
            order: 1,
            isVisible: true,
          ),
          SocialLink(
            id: 'link_zalo_2',
            type: SocialLinkType.zalo,
            value: 'https://zalo.me/0912345678',
            label: 'Zalo',
            order: 2,
            isVisible: true,
          ),
        ],
        isDefault: false,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
    ];
  }
}
