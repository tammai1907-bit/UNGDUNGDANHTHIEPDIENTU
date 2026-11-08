import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/business_card.dart';
import 'card_repository_provider.dart';
import 'current_user_provider.dart';

/// StreamProvider lắng nghe danh sách thẻ của người dùng hiện tại theo thời gian thực
final myCardsStreamProvider = StreamProvider.autoDispose<List<BusinessCard>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(cardRepositoryProvider);
  return repo.watchCards(userId);
});

/// Trạng thái AsyncValue cho các hành động trên danh sách thẻ (xóa, nhân bản, đặt mặc định)
class CardListController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CardListController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> deleteCard(String cardId) async {
    state = const AsyncValue.loading();
    final userId = _ref.read(currentUserIdProvider);
    final repo = _ref.read(cardRepositoryProvider);

    final res = await repo.deleteCard(userId: userId, cardId: cardId);
    return res.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> duplicateCard(String cardId) async {
    state = const AsyncValue.loading();
    final userId = _ref.read(currentUserIdProvider);
    final repo = _ref.read(cardRepositoryProvider);
    final newId = const Uuid().v4();

    final res = await repo.duplicateCard(
      userId: userId,
      cardId: cardId,
      newId: newId,
    );

    return res.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> setDefaultCard(String cardId) async {
    state = const AsyncValue.loading();
    final userId = _ref.read(currentUserIdProvider);
    final repo = _ref.read(cardRepositoryProvider);

    final res = await repo.setDefaultCard(userId: userId, cardId: cardId);
    return res.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }
}

final cardListControllerProvider =
    StateNotifierProvider.autoDispose<CardListController, AsyncValue<void>>((ref) {
  return CardListController(ref);
});
