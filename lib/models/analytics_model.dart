import 'dart:convert';

class CardAnalyticsModel {
  final String cardId;
  final int totalViews;
  final int totalSaves;
  final int qrScans;
  final int nfcTaps;
  final Map<String, int> clickThroughRates; // 'phone': 12, 'email': 8, 'linkedin': 15, 'website': 7
  final Map<String, int> dailyViews; // '2026-10-11': 5, '2026-10-12': 12...

  const CardAnalyticsModel({
    required this.cardId,
    this.totalViews = 0,
    this.totalSaves = 0,
    this.qrScans = 0,
    this.nfcTaps = 0,
    this.clickThroughRates = const {},
    this.dailyViews = const {},
  });

  CardAnalyticsModel copyWith({
    String? cardId,
    int? totalViews,
    int? totalSaves,
    int? qrScans,
    int? nfcTaps,
    Map<String, int>? clickThroughRates,
    Map<String, int>? dailyViews,
  }) {
    return CardAnalyticsModel(
      cardId: cardId ?? this.cardId,
      totalViews: totalViews ?? this.totalViews,
      totalSaves: totalSaves ?? this.totalSaves,
      qrScans: qrScans ?? this.qrScans,
      nfcTaps: nfcTaps ?? this.nfcTaps,
      clickThroughRates: clickThroughRates ?? this.clickThroughRates,
      dailyViews: dailyViews ?? this.dailyViews,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'totalViews': totalViews,
      'totalSaves': totalSaves,
      'qrScans': qrScans,
      'nfcTaps': nfcTaps,
      'clickThroughRates': jsonEncode(clickThroughRates),
      'dailyViews': jsonEncode(dailyViews),
    };
  }

  factory CardAnalyticsModel.fromMap(Map<String, dynamic> map) {
    Map<String, int> parsedClicks = {};
    if (map['clickThroughRates'] != null) {
      try {
        final decoded = jsonDecode(map['clickThroughRates'] as String);
        if (decoded is Map) {
          parsedClicks = decoded.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        }
      } catch (_) {}
    }

    Map<String, int> parsedDaily = {};
    if (map['dailyViews'] != null) {
      try {
        final decoded = jsonDecode(map['dailyViews'] as String);
        if (decoded is Map) {
          parsedDaily = decoded.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        }
      } catch (_) {}
    }

    return CardAnalyticsModel(
      cardId: map['cardId'] as String,
      totalViews: (map['totalViews'] as num?)?.toInt() ?? 0,
      totalSaves: (map['totalSaves'] as num?)?.toInt() ?? 0,
      qrScans: (map['qrScans'] as num?)?.toInt() ?? 0,
      nfcTaps: (map['nfcTaps'] as num?)?.toInt() ?? 0,
      clickThroughRates: parsedClicks,
      dailyViews: parsedDaily,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CardAnalyticsModel.fromJson(String source) =>
      CardAnalyticsModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
