import '../entities/card_analytics.dart';

abstract class AnalyticsRepository {
  Future<CardAnalytics> getAnalyticsForCard(String cardId);
  Future<void> recordEvent({
    required String cardId,
    required String eventType, // 'view', 'save', 'qr_scan', 'nfc_tap', 'link_click'
    String? linkType,
  });
}
