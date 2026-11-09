import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/analytics/data/repositories/fake_analytics_repository.dart';

void main() {
  group('FakeAnalyticsRepository Tests', () {
    late FakeAnalyticsRepository repository;

    setUp(() {
      repository = FakeAnalyticsRepository();
    });

    test('Lấy dữ liệu phân tích thống kê hợp lệ', () async {
      final analytics = await repository.getAnalyticsForCard('card_official_01');

      expect(analytics.totalViews, greaterThan(0));
      expect(analytics.totalSaves, greaterThan(0));
      expect(analytics.totalQrScans, greaterThan(0));
      expect(analytics.totalNfcTaps, greaterThan(0));
      expect(analytics.dailyStats.length, 7);
      expect(analytics.linkClicks.isNotEmpty, isTrue);
    });
  });
}
