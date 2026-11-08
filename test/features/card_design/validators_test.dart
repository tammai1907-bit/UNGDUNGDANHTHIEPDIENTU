import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/core/validators/card_validators.dart';
import 'package:digital_business_card/features/card_design/domain/entities/social_link.dart';

void main() {
  group('CardValidators Tests', () {
    test('validateRequired returns error when empty', () {
      expect(CardValidators.validateRequired('', fieldName: 'Họ tên'), isNotNull);
      expect(CardValidators.validateRequired('   ', fieldName: 'Họ tên'), isNotNull);
      expect(CardValidators.validateRequired('Mai Văn Tâm', fieldName: 'Họ tên'), isNull);
    });

    test('validateEmail validates correctly', () {
      expect(CardValidators.validateEmail('tam.mai@techcorp.vn'), isNull);
      expect(CardValidators.validateEmail('invalid-email'), isNotNull);
      expect(CardValidators.validateEmail(''), isNull); // Optional
    });

    test('validatePhoneVN validates Vietnamese phone numbers', () {
      expect(CardValidators.validatePhoneVN('0987654321'), isNull);
      expect(CardValidators.validatePhoneVN('+84987654321'), isNull);
      expect(CardValidators.validatePhoneVN('0381234567'), isNull);
      expect(CardValidators.validatePhoneVN('12345'), isNotNull);
    });

    test('normalizePhoneVN formats correctly', () {
      expect(CardValidators.normalizePhoneVN('0987 654 321'), '0987654321');
      expect(CardValidators.normalizePhoneVN('+84987654321'), '0987654321');
    });

    test('normalizeSocialUrl generates proper URIs', () {
      // Zalo
      expect(
        CardValidators.normalizeSocialUrl(SocialLinkType.zalo, '0987654321'),
        'https://zalo.me/0987654321',
      );
      // GitHub
      expect(
        CardValidators.normalizeSocialUrl(SocialLinkType.github, 'maivantam'),
        'https://github.com/maivantam',
      );
      // LinkedIn
      expect(
        CardValidators.normalizeSocialUrl(SocialLinkType.linkedin, 'maivantam-dev'),
        'https://linkedin.com/in/maivantam-dev',
      );
      // Phone
      expect(
        CardValidators.normalizeSocialUrl(SocialLinkType.phone, '0987654321'),
        'tel:0987654321',
      );
      // Email
      expect(
        CardValidators.normalizeSocialUrl(SocialLinkType.email, 'tam.mai@techcorp.vn'),
        'mailto:tam.mai@techcorp.vn',
      );
    });
  });
}
