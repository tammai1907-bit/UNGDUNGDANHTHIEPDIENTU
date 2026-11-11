import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/sharing/utils/qr_link_parser.dart';

void main() {
  group('QrLinkParser Tests', () {
    test('Phân tích đúng URL chuẩn https://card.maitam1907.dev/c/{ownerId}/{cardId}', () {
      const url = 'https://card.maitam1907.dev/c/user_current/card_official_01';
      final info = QrLinkParser.parse(url);

      expect(info, isNotNull);
      expect(info?.ownerId, 'user_current');
      expect(info?.cardId, 'card_official_01');
    });

    test('Phân tích URL có query parameters', () {
      const url = 'https://mydomain.vn/share?ownerId=usr_99&cardId=card_99';
      final info = QrLinkParser.parse(url);

      expect(info, isNotNull);
      expect(info?.ownerId, 'usr_99');
      expect(info?.cardId, 'card_99');
    });

    test('Phân tích custom scheme card://usr_123/card_456', () {
      const url = 'card://usr_123/card_456';
      final info = QrLinkParser.parse(url);

      expect(info, isNotNull);
      expect(info?.ownerId, 'usr_123');
      expect(info?.cardId, 'card_456');
    });

    test('Trả về null nếu đường dẫn rỗng hoặc không đúng định dạng', () {
      expect(QrLinkParser.parse(''), isNull);
      expect(QrLinkParser.parse('   '), isNull);
      expect(QrLinkParser.parse('https://google.com'), isNull);
      expect(QrLinkParser.parse('random_text_not_url'), isNull);
    });

    test('isValidCardUrl hoạt động chính xác', () {
      expect(QrLinkParser.isValidCardUrl('https://card.maitam1907.dev/c/usr/card'), isTrue);
      expect(QrLinkParser.isValidCardUrl('https://facebook.com'), isFalse);
    });
  });
}
