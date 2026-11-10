class DailyInteraction {
  final DateTime date;
  final int views;
  final int saves;
  final int qrScans;
  final int nfcTaps;

  const DailyInteraction({
    required this.date,
    required this.views,
    required this.saves,
    required this.qrScans,
    required this.nfcTaps,
  });

  int get total => views + saves + qrScans + nfcTaps;

  DailyInteraction copyWith({
    DateTime? date,
    int? views,
    int? saves,
    int? qrScans,
    int? nfcTaps,
  }) {
    return DailyInteraction(
      date: date ?? this.date,
      views: views ?? this.views,
      saves: saves ?? this.saves,
      qrScans: qrScans ?? this.qrScans,
      nfcTaps: nfcTaps ?? this.nfcTaps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'views': views,
      'saves': saves,
      'qrScans': qrScans,
      'nfcTaps': nfcTaps,
    };
  }

  factory DailyInteraction.fromMap(Map<String, dynamic> map) {
    return DailyInteraction(
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      views: map['views'] as int? ?? 0,
      saves: map['saves'] as int? ?? 0,
      qrScans: map['qrScans'] as int? ?? 0,
      nfcTaps: map['nfcTaps'] as int? ?? 0,
    );
  }
}

class LinkClickStat {
  final String label;
  final String type;
  final int clicks;
  final double percentage;

  const LinkClickStat({
    required this.label,
    required this.type,
    required this.clicks,
    required this.percentage,
  });

  LinkClickStat copyWith({
    String? label,
    String? type,
    int? clicks,
    double? percentage,
  }) {
    return LinkClickStat(
      label: label ?? this.label,
      type: type ?? this.type,
      clicks: clicks ?? this.clicks,
      percentage: percentage ?? this.percentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'type': type,
      'clicks': clicks,
      'percentage': percentage,
    };
  }

  factory LinkClickStat.fromMap(Map<String, dynamic> map) {
    return LinkClickStat(
      label: map['label'] as String? ?? '',
      type: map['type'] as String? ?? '',
      clicks: map['clicks'] as int? ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CardAnalytics {
  final String cardId;
  final int totalViews;
  final int totalSaves;
  final int totalQrScans;
  final int totalNfcTaps;
  final List<DailyInteraction> dailyStats;
  final List<LinkClickStat> linkClicks;

  const CardAnalytics({
    required this.cardId,
    required this.totalViews,
    required this.totalSaves,
    required this.totalQrScans,
    required this.totalNfcTaps,
    required this.dailyStats,
    required this.linkClicks,
  });

  int get totalInteractions => totalViews + totalSaves + totalQrScans + totalNfcTaps;

  CardAnalytics copyWith({
    String? cardId,
    int? totalViews,
    int? totalSaves,
    int? totalQrScans,
    int? totalNfcTaps,
    List<DailyInteraction>? dailyStats,
    List<LinkClickStat>? linkClicks,
  }) {
    return CardAnalytics(
      cardId: cardId ?? this.cardId,
      totalViews: totalViews ?? this.totalViews,
      totalSaves: totalSaves ?? this.totalSaves,
      totalQrScans: totalQrScans ?? this.totalQrScans,
      totalNfcTaps: totalNfcTaps ?? this.totalNfcTaps,
      dailyStats: dailyStats ?? this.dailyStats,
      linkClicks: linkClicks ?? this.linkClicks,
    );
  }
}
