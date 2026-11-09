import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/domain/entities/card_design.dart';
import 'package:digital_business_card/features/card_design/domain/entities/social_link.dart';
import 'package:digital_business_card/features/sharing/utils/vcard_generator.dart';

void main() {
  group('VCardGenerator Tests', () {
    test('Sinh chuỗi vCard 3.0 với đầy đủ các trường thông tin chuẩn', () {
      final card = BusinessCard(
        id: 'card_01',
        ownerId: 'user_01',
        cardName: 'Thẻ Công Việc',
        fullName: 'Mai Văn Tâm',
        jobTitle: 'Senior Flutter Engineer',
        company: 'TechCorp Vietnam',
        phone: '0987654321',
        email: 'tammai1907@gmail.com',
        website: 'https://maivantam.dev',
        address: 'Quận 1, TP. Hồ Chí Minh',
        bio: 'Lập trình viên di động Flutter nhiệt huyết',
        design: CardDesign.fromHex(
          templateId: 'modern',
          primaryColorHex: '#1565C0',
          secondaryColorHex: '#0D47A1',
          backgroundColorHex: '#FFFFFF',
          textColorHex: '#000000',
        ),
        socialLinks: [
          SocialLink(
            id: 'l1',
            type: SocialLinkType.github,
            value: 'https://github.com/maivantam',
            order: 0,
            isVisible: true,
          ),
        ],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final vcard = VCardGenerator.generateVCardString(card);

      expect(vcard, contains('BEGIN:VCARD'));
      expect(vcard, contains('VERSION:3.0'));
      expect(vcard, contains('FN:Mai Văn Tâm'));
      expect(vcard, contains('N:Tâm;Mai Văn;;;'));
      expect(vcard, contains('ORG:TechCorp Vietnam'));
      expect(vcard, contains('TITLE:Senior Flutter Engineer'));
      expect(vcard, contains('TEL;TYPE=CELL,VOICE:0987654321'));
      expect(vcard, contains('EMAIL;TYPE=INTERNET,PREF:tammai1907@gmail.com'));
      expect(vcard, contains('URL:https://maivantam.dev'));
      expect(vcard, contains('ADR;TYPE=WORK:;;Quận 1, TP. Hồ Chí Minh;;;;'));
      expect(vcard, contains('NOTE:Lập trình viên di động Flutter nhiệt huyết'));
      expect(vcard, contains('URL;TYPE=GITHUB:https://github.com/maivantam'));
      expect(vcard, contains('END:VCARD'));
    });
  });
}
