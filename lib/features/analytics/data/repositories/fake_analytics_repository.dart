import 'dart:async';
import '../../domain/entities/card_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class FakeAnalyticsRepository implements AnalyticsRepository {
  final Map<String, CardAnalytics> _analyticsStore = {};
  final StreamController<Map<String, CardAnalytics>> _streamController =
      StreamController<Map<String, CardAnalytics>>.broadcast();

  CardAnalytics _getOrInitCardAnalytics(String cardId) {
    if (_analyticsStore.containsKey(cardId)) {
      return _analyticsStore[cardId]!;
    }

    final now = DateTime.now();
    // Khởi tạo 7 ngày gần nhất với dữ liệu phân bố thực tế
    final daily = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      // Tăng dần theo các ngày trong tuần
      final dayFactor = i + 1;
      return DailyInteraction(
        date: date,
        views: 12 + (dayFactor * 4),
        saves: 2 + (dayFactor * 2),
        qrScans: 6 + (dayFactor * 3),
        nfcTaps: 4 + (dayFactor * 2),
      );
    });

    final linkClicks = [
      const LinkClickStat(label: 'LinkedIn', type: 'linkedin', clicks: 68, percentage: 38.0),
      const LinkClickStat(label: 'Số Điện Thoại (Gọi)', type: 'phone', clicks: 45, percentage: 25.0),
      const LinkClickStat(label: 'Zalo', type: 'zalo', clicks: 32, percentage: 18.0),
      const LinkClickStat(label: 'Website Công Ty', type: 'website', clicks: 20, percentage: 11.0),
      const LinkClickStat(label: 'Email', type: 'email', clicks: 15, percentage: 8.0),
    ];

    final initial = CardAnalytics(
      cardId: cardId,
      totalViews: 142,
      totalSaves: 38,
      totalQrScans: 85,
      totalNfcTaps: 57,
      dailyStats: daily,
      linkClicks: linkClicks,
    );

    _analyticsStore[cardId] = initial;
    return initial;
  }

  @override
  Future<CardAnalytics> getAnalyticsForCard(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _getOrInitCardAnalytics(cardId);
  }

  @override
  Stream<CardAnalytics> watchAnalyticsForCard(String cardId) {
    _getOrInitCardAnalytics(cardId);
    return _streamController.stream
        .map((store) => store[cardId] ?? _getOrInitCardAnalytics(cardId))
        .asBroadcastStream(
          onListen: (subscription) {
            _streamController.add(Map.unmodifiable(_analyticsStore));
          },
        );
  }

  @override
  Future<void> recordEvent({
    required String cardId,
    required String eventType,
    String? linkType,
  }) async {
    final current = _getOrInitCardAnalytics(cardId);

    int newViews = current.totalViews;
    int newSaves = current.totalSaves;
    int newQrScans = current.totalQrScans;
    int newNfcTaps = current.totalNfcTaps;

    final updatedDaily = List<DailyInteraction>.from(current.dailyStats);
    if (updatedDaily.isNotEmpty) {
      final todayIndex = updatedDaily.length - 1;
      final today = updatedDaily[todayIndex];

      if (eventType == 'view') {
        newViews += 1;
        updatedDaily[todayIndex] = today.copyWith(views: today.views + 1);
      } else if (eventType == 'qr_scan') {
        newQrScans += 1;
        newViews += 1;
        updatedDaily[todayIndex] = today.copyWith(
          qrScans: today.qrScans + 1,
          views: today.views + 1,
        );
      } else if (eventType == 'nfc_tap') {
        newNfcTaps += 1;
        newViews += 1;
        updatedDaily[todayIndex] = today.copyWith(
          nfcTaps: today.nfcTaps + 1,
          views: today.views + 1,
        );
      } else if (eventType == 'save') {
        newSaves += 1;
        updatedDaily[todayIndex] = today.copyWith(saves: today.saves + 1);
      }
    }

    // Xử lý Click liên kết mạng xã hội & liên hệ
    List<LinkClickStat> updatedLinks = List.from(current.linkClicks);
    if (eventType == 'link_click' && linkType != null && linkType.isNotEmpty) {
      final index = updatedLinks.indexWhere((l) => l.type == linkType);
      if (index >= 0) {
        final existing = updatedLinks[index];
        updatedLinks[index] = existing.copyWith(clicks: existing.clicks + 1);
      } else {
        // Thêm liên kết mới nếu chưa có trong danh sách
        String label = linkType;
        if (linkType == 'linkedin') label = 'LinkedIn';
        if (linkType == 'phone') label = 'Số Điện Thoại (Gọi)';
        if (linkType == 'email') label = 'Email';
        if (linkType == 'website') label = 'Website';
        if (linkType == 'zalo') label = 'Zalo';
        if (linkType == 'github') label = 'GitHub';
        if (linkType == 'facebook') label = 'Facebook';

        updatedLinks.add(LinkClickStat(
          label: label,
          type: linkType,
          clicks: 1,
          percentage: 0,
        ));
      }

      // Tính toán lại tỷ lệ % CTR cho tất cả các liên kết
      final totalClicks = updatedLinks.fold<int>(0, (sum, item) => sum + item.clicks);
      if (totalClicks > 0) {
        updatedLinks = updatedLinks.map((item) {
          final pct = (item.clicks / totalClicks) * 100.0;
          return item.copyWith(percentage: double.parse(pct.toStringAsFixed(1)));
        }).toList();
      }
    }

    final updatedAnalytics = current.copyWith(
      totalViews: newViews,
      totalSaves: newSaves,
      totalQrScans: newQrScans,
      totalNfcTaps: newNfcTaps,
      dailyStats: updatedDaily,
      linkClicks: updatedLinks,
    );

    _analyticsStore[cardId] = updatedAnalytics;
    _streamController.add(Map.unmodifiable(_analyticsStore));
  }
}
