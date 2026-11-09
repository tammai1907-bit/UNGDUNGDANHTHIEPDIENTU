import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart' show useMockDataProvider;
import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/analytics/domain/entities/card_analytics.dart';
import 'package:digital_business_card/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:digital_business_card/features/analytics/data/repositories/fake_analytics_repository.dart';
import 'package:digital_business_card/features/analytics/data/repositories/firebase_analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  if (useMock) {
    return FakeAnalyticsRepository();
  }
  return FirebaseAnalyticsRepository();
});

final selectedAnalyticsCardIdProvider = StateProvider<String?>((ref) => null);

final cardAnalyticsFutureProvider = FutureProvider<CardAnalytics>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final List<BusinessCard> cards = await ref.watch(myCardsStreamProvider.future);

  if (cards.isEmpty) {
    return const CardAnalytics(
      cardId: '',
      totalViews: 0,
      totalSaves: 0,
      totalQrScans: 0,
      totalNfcTaps: 0,
      dailyStats: [],
      linkClicks: [],
    );
  }

  final selectedId = ref.watch(selectedAnalyticsCardIdProvider);
  final targetCard = cards.firstWhere(
    (c) => c.id == selectedId,
    orElse: () => cards.firstWhere((c) => c.isDefault, orElse: () => cards.first),
  );

  return repo.getAnalyticsForCard(targetCard.id);
});
