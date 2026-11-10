import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/card_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _firestore;

  FirebaseAnalyticsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CardAnalytics> getAnalyticsForCard(String cardId) async {
    final doc = await _summaryRef(cardId).get();
    return doc.exists && doc.data() != null
        ? _parseAnalytics(cardId, doc.data()!)
        : _emptyAnalytics(cardId);
  }

  @override
  Stream<CardAnalytics> watchAnalyticsForCard(String cardId) {
    return _summaryRef(cardId).snapshots().map((snapshot) {
      return snapshot.exists && snapshot.data() != null
          ? _parseAnalytics(cardId, snapshot.data()!)
          : _emptyAnalytics(cardId);
    });
  }

  DocumentReference<Map<String, dynamic>> _summaryRef(String cardId) {
    return _firestore
        .collection('cards')
        .doc(cardId)
        .collection('analytics')
        .doc('summary');
  }

  CardAnalytics _emptyAnalytics(String cardId) {
    return CardAnalytics(
      cardId: cardId,
      totalViews: 0,
      totalSaves: 0,
      totalQrScans: 0,
      totalNfcTaps: 0,
      dailyStats: const [],
      linkClicks: const [],
    );
  }

  CardAnalytics _parseAnalytics(String cardId, Map<String, dynamic> data) {
    final dailyList =
        (data['dailyStats'] as List<dynamic>?)
            ?.map(
              (e) =>
                  DailyInteraction.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];

    final linksList =
        (data['linkClicks'] as List<dynamic>?)
            ?.map(
              (e) => LinkClickStat.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];

    return CardAnalytics(
      cardId: cardId,
      totalViews: data['totalViews'] as int? ?? 0,
      totalSaves: data['totalSaves'] as int? ?? 0,
      totalQrScans: data['totalQrScans'] as int? ?? 0,
      totalNfcTaps: data['totalNfcTaps'] as int? ?? 0,
      dailyStats: dailyList,
      linkClicks: linksList,
    );
  }

  @override
  Future<void> recordEvent({
    required String cardId,
    required String eventType,
    String? linkType,
  }) async {
    const supportedEvents = {
      'view',
      'save',
      'qr_scan',
      'nfc_tap',
      'link_click',
    };
    if (!supportedEvents.contains(eventType)) {
      throw ArgumentError.value(
        eventType,
        'eventType',
        'Unsupported analytics event',
      );
    }
    if (eventType == 'link_click' && (linkType == null || linkType.isEmpty)) {
      throw ArgumentError.value(
        linkType,
        'linkType',
        'A link type is required for link_click events',
      );
    }

    final summaryRef = _summaryRef(cardId);
    final eventRef = _firestore
        .collection('cards')
        .doc(cardId)
        .collection('events')
        .doc();
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);
      final current = snapshot.exists && snapshot.data() != null
          ? _parseAnalytics(cardId, snapshot.data()!)
          : _emptyAnalytics(cardId);

      final countsView =
          eventType == 'view' ||
          eventType == 'qr_scan' ||
          eventType == 'nfc_tap';
      final updatedViews = current.totalViews + (countsView ? 1 : 0);
      final updatedAnalytics = CardAnalytics(
        cardId: cardId,
        totalViews: updatedViews,
        totalSaves: current.totalSaves + (eventType == 'save' ? 1 : 0),
        totalQrScans: current.totalQrScans + (eventType == 'qr_scan' ? 1 : 0),
        totalNfcTaps: current.totalNfcTaps + (eventType == 'nfc_tap' ? 1 : 0),
        dailyStats: _updateDailyStats(current.dailyStats, eventType, now),
        linkClicks: eventType == 'link_click'
            ? _updateLinkClicks(current.linkClicks, linkType!)
            : current.linkClicks,
      );

      transaction.set(summaryRef, {
        'totalViews': updatedAnalytics.totalViews,
        'totalSaves': updatedAnalytics.totalSaves,
        'totalQrScans': updatedAnalytics.totalQrScans,
        'totalNfcTaps': updatedAnalytics.totalNfcTaps,
        'dailyStats': updatedAnalytics.dailyStats
            .map((stat) => stat.toMap())
            .toList(),
        'linkClicks': updatedAnalytics.linkClicks
            .map((stat) => stat.toMap())
            .toList(),
      });
      transaction.set(eventRef, {
        'type': eventType,
        'linkType': linkType,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  List<DailyInteraction> _updateDailyStats(
    List<DailyInteraction> existingStats,
    String eventType,
    DateTime now,
  ) {
    final statsByDate = {
      for (final stat in existingStats) _dateKey(stat.date): stat,
    };

    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - (6 - index));
      final existing =
          statsByDate[_dateKey(date)] ??
          DailyInteraction(
            date: date,
            views: 0,
            saves: 0,
            qrScans: 0,
            nfcTaps: 0,
          );
      final isToday = index == 6;

      return existing.copyWith(
        date: date,
        views:
            existing.views +
            (isToday &&
                    (eventType == 'view' ||
                        eventType == 'qr_scan' ||
                        eventType == 'nfc_tap')
                ? 1
                : 0),
        saves: existing.saves + (isToday && eventType == 'save' ? 1 : 0),
        qrScans: existing.qrScans + (isToday && eventType == 'qr_scan' ? 1 : 0),
        nfcTaps: existing.nfcTaps + (isToday && eventType == 'nfc_tap' ? 1 : 0),
      );
    });
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  List<LinkClickStat> _updateLinkClicks(
    List<LinkClickStat> currentLinks,
    String linkType,
  ) {
    final links = List<LinkClickStat>.from(currentLinks);
    final index = links.indexWhere((link) => link.type == linkType);
    if (index >= 0) {
      final link = links[index];
      links[index] = link.copyWith(clicks: link.clicks + 1);
    } else {
      links.add(
        LinkClickStat(
          label: _linkLabel(linkType),
          type: linkType,
          clicks: 1,
          percentage: 0,
        ),
      );
    }

    final totalClicks = links.fold<int>(
      0,
      (total, link) => total + link.clicks,
    );
    return links
        .map(
          (link) => link.copyWith(
            percentage: totalClicks == 0
                ? 0
                : (link.clicks / totalClicks) * 100,
          ),
        )
        .toList();
  }

  String _linkLabel(String type) {
    switch (type) {
      case 'linkedin':
        return 'LinkedIn';
      case 'phone':
        return 'Số Điện Thoại (Gọi)';
      case 'email':
        return 'Email';
      case 'website':
        return 'Website';
      case 'zalo':
        return 'Zalo';
      case 'github':
        return 'GitHub';
      case 'facebook':
        return 'Facebook';
      default:
        return type;
    }
  }
}
