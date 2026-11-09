import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/card_analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _firestore;

  FirebaseAnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CardAnalytics> getAnalyticsForCard(String cardId) async {
    try {
      final doc = await _firestore.collection('cards').doc(cardId).collection('analytics').doc('summary').get();

      if (!doc.exists || doc.data() == null) {
        // Trả về dữ liệu khởi tạo nếu chưa có bản ghi
        return CardAnalytics(
          cardId: cardId,
          totalViews: 0,
          totalSaves: 0,
          totalQrScans: 0,
          totalNfcTaps: 0,
          dailyStats: [],
          linkClicks: [],
        );
      }

      final data = doc.data()!;
      return CardAnalytics(
        cardId: cardId,
        totalViews: data['totalViews'] as int? ?? 0,
        totalSaves: data['totalSaves'] as int? ?? 0,
        totalQrScans: data['totalQrScans'] as int? ?? 0,
        totalNfcTaps: data['totalNfcTaps'] as int? ?? 0,
        dailyStats: [],
        linkClicks: [],
      );
    } catch (_) {
      return CardAnalytics(
        cardId: cardId,
        totalViews: 0,
        totalSaves: 0,
        totalQrScans: 0,
        totalNfcTaps: 0,
        dailyStats: [],
        linkClicks: [],
      );
    }
  }

  @override
  Future<void> recordEvent({
    required String cardId,
    required String eventType,
    String? linkType,
  }) async {
    final batch = _firestore.batch();
    final summaryRef = _firestore.collection('cards').doc(cardId).collection('analytics').doc('summary');

    String field = 'totalViews';
    if (eventType == 'save') field = 'totalSaves';
    if (eventType == 'qr_scan') field = 'totalQrScans';
    if (eventType == 'nfc_tap') field = 'totalNfcTaps';

    batch.set(summaryRef, {field: FieldValue.increment(1)}, SetOptions(merge: true));

    final eventRef = _firestore.collection('cards').doc(cardId).collection('events').doc();
    batch.set(eventRef, {
      'type': eventType,
      'linkType': linkType,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
