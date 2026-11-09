import '../../domain/entities/card_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<CardAnalytics> getAnalyticsForCard(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final now = DateTime.now();
    // 7 ngày gần nhất
    final daily = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DailyInteraction(
        date: date,
        views: 15 + (i * 3) % 11,
        saves: 4 + (i * 2) % 5,
        qrScans: 8 + (i * 4) % 9,
        nfcTaps: 5 + (i * 2) % 7,
      );
    });

    final linkClicks = [
      const LinkClickStat(label: 'LinkedIn', type: 'linkedin', clicks: 68, percentage: 38.0),
      const LinkClickStat(label: 'Số Điện Thoại (Gọi)', type: 'phone', clicks: 45, percentage: 25.0),
      const LinkClickStat(label: 'Zalo', type: 'zalo', clicks: 32, percentage: 18.0),
      const LinkClickStat(label: 'GitHub', type: 'github', clicks: 20, percentage: 11.0),
      const LinkClickStat(label: 'Email', type: 'email', clicks: 15, percentage: 8.0),
    ];

    return CardAnalytics(
      cardId: cardId,
      totalViews: 142,
      totalSaves: 38,
      totalQrScans: 85,
      totalNfcTaps: 57,
      dailyStats: daily,
      linkClicks: linkClicks,
    );
  }

  @override
  Future<void> recordEvent({
    required String cardId,
    required String eventType,
    String? linkType,
  }) async {
    // Ghi nhận sự kiện giả lập thành công
  }
}
