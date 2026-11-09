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
}
