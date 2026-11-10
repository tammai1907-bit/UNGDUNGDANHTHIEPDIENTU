import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/analytics/data/repositories/fake_analytics_repository.dart';

void main() {
  group('FakeAnalyticsRepository Tests', () {
    late FakeAnalyticsRepository repository;
    const testCardId = 'card_official_01';

    setUp(() {
      repository = FakeAnalyticsRepository();
    });

    test('Lấy dữ liệu phân tích thống kê hợp lệ', () async {
      final analytics = await repository.getAnalyticsForCard(testCardId);

      expect(analytics.totalViews, greaterThan(0));
      expect(analytics.totalSaves, greaterThan(0));
      expect(analytics.totalQrScans, greaterThan(0));
      expect(analytics.totalNfcTaps, greaterThan(0));
      expect(analytics.dailyStats.length, 7);
      expect(analytics.linkClicks.isNotEmpty, isTrue);
    });

    test('Ghi nhận sự kiện xem thẻ làm tăng totalViews trong thời gian thực', () async {
      final before = await repository.getAnalyticsForCard(testCardId);
      final initialViews = before.totalViews;

      await repository.recordEvent(cardId: testCardId, eventType: 'view');

      final after = await repository.getAnalyticsForCard(testCardId);
      expect(after.totalViews, initialViews + 1);
    });

    test('Ghi nhận sự kiện quét QR làm tăng totalQrScans và totalViews', () async {
      final before = await repository.getAnalyticsForCard(testCardId);
      final initialQr = before.totalQrScans;
      final initialViews = before.totalViews;

      await repository.recordEvent(cardId: testCardId, eventType: 'qr_scan');

      final after = await repository.getAnalyticsForCard(testCardId);
      expect(after.totalQrScans, initialQr + 1);
      expect(after.totalViews, initialViews + 1);
    });

    test('Ghi nhận sự kiện chạm NFC làm tăng totalNfcTaps và totalViews', () async {
      final before = await repository.getAnalyticsForCard(testCardId);
      final initialNfc = before.totalNfcTaps;

      await repository.recordEvent(cardId: testCardId, eventType: 'nfc_tap');

      final after = await repository.getAnalyticsForCard(testCardId);
      expect(after.totalNfcTaps, initialNfc + 1);
    });

    test('Ghi nhận sự kiện lưu danh bạ làm tăng totalSaves', () async {
      final before = await repository.getAnalyticsForCard(testCardId);
      final initialSaves = before.totalSaves;

      await repository.recordEvent(cardId: testCardId, eventType: 'save');

      final after = await repository.getAnalyticsForCard(testCardId);
      expect(after.totalSaves, initialSaves + 1);
    });

    test('Ghi nhận click liên kết mạng xã hội cập nhật lượt click và CTR %', () async {
      await repository.recordEvent(cardId: testCardId, eventType: 'link_click', linkType: 'linkedin');

      final after = await repository.getAnalyticsForCard(testCardId);
      final linkedin = after.linkClicks.firstWhere((l) => l.type == 'linkedin');
      expect(linkedin.clicks, greaterThan(0));
      expect(linkedin.percentage, greaterThan(0));
    });
  });
}
