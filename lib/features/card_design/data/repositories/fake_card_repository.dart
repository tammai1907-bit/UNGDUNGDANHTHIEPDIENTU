import 'dart:async';
import '../../../../core/constants/card_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../services/database_service.dart';
import '../../domain/entities/business_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_seed_data.dart';
import '../models/card_sync_mapper.dart';

/// Bản cài đặt Fake InMemory của CardRepository để chạy độc lập không phụ thuộc Firebase
/// Tự động đồng bộ với SQLite DatabaseService để các màn hình khác trong app phản ánh ngay thay đổi.
class FakeCardRepository implements CardRepository {
  final Map<String, List<BusinessCard>> _storage = {};
  final Map<String, StreamController<List<BusinessCard>>> _controllers = {};

  StreamController<List<BusinessCard>> _getController(String userId) {
    if (!_controllers.containsKey(userId)) {
      _controllers[userId] = StreamController<List<BusinessCard>>.broadcast();
    }
    return _controllers[userId]!;
  }

  void _notify(String userId) {
    final list = _storage[userId] ?? [];
    _getController(userId).add(List.unmodifiable(list));
  }

  void _ensureInitialized(String userId) {
    if (!_storage.containsKey(userId)) {
      _storage[userId] = CardSeedData.getInitialCards(userId);
      // Tự động nạp dữ liệu từ SQLite nếu có sẵn
      try {
        DatabaseService.instance.getAllProfiles().then((profiles) {
          if (profiles.isNotEmpty) {
            _storage[userId] = profiles.map(CardSyncMapper.toDomain).toList();
            _notify(userId);
          }
        }).catchError((_) {});
      } catch (_) {}
    }
  }

  @override
  Stream<List<BusinessCard>> watchCards(String userId) {
    _ensureInitialized(userId);
    // Gửi ngay giá trị khởi tạo khi stream vừa lắng nghe
    Future.microtask(() => _notify(userId));
    return _getController(userId).stream;
  }

  @override
  Future<Result<List<BusinessCard>>> getCards(String userId) async {
    _ensureInitialized(userId);
    await Future.delayed(const Duration(milliseconds: 100));
    return Result.success(List.unmodifiable(_storage[userId] ?? []));
  }

  @override
  Future<Result<BusinessCard>> getCardById({
    required String userId,
    required String cardId,
  }) async {
    _ensureInitialized(userId);
    final userCards = _storage[userId] ?? [];
    try {
      final card = userCards.firstWhere((c) => c.id == cardId);
      return Result.success(card);
    } catch (_) {
      return Result.failure(Exception('Không tìm thấy danh thiếp với ID: $cardId'));
    }
  }

  @override
  Future<Result<void>> createCard(BusinessCard card) async {
    _ensureInitialized(card.ownerId);
    final userCards = _storage[card.ownerId]!;

    if (userCards.length >= CardConstants.maxCardsPerUser) {
      return Result.failure(
        Exception('Bạn đã đạt giới hạn tối đa ${CardConstants.maxCardsPerUser} danh thiếp.'),
      );
    }

    // Nếu thẻ này là thẻ đầu tiên hoặc được đánh dấu mặc định, cập nhật các thẻ khác
    if (userCards.isEmpty || card.isDefault) {
      for (int i = 0; i < userCards.length; i++) {
        userCards[i] = userCards[i].copyWith(isDefault: false);
      }
    }

    userCards.add(card);
    _notify(card.ownerId);

    // Đồng bộ vào SQLite
    try {
      await DatabaseService.instance.insertProfile(CardSyncMapper.toModel(card));
    } catch (_) {}

    return Result.success(null);
  }

  @override
  Future<Result<void>> updateCard(BusinessCard card) async {
    _ensureInitialized(card.ownerId);
    final userCards = _storage[card.ownerId]!;
    final index = userCards.indexWhere((c) => c.id == card.id);

    if (index == -1) {
      return Result.failure(Exception('Không tìm thấy danh thiếp để cập nhật'));
    }

    if (card.isDefault) {
      for (int i = 0; i < userCards.length; i++) {
        if (i != index) {
          userCards[i] = userCards[i].copyWith(isDefault: false);
        }
      }
    }

    userCards[index] = card.copyWith(updatedAt: DateTime.now());
    _notify(card.ownerId);

    // Đồng bộ vào SQLite
    try {
      await DatabaseService.instance.updateProfile(CardSyncMapper.toModel(card));
    } catch (_) {}

    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteCard({
    required String userId,
    required String cardId,
  }) async {
    _ensureInitialized(userId);
    final userCards = _storage[userId]!;
    final index = userCards.indexWhere((c) => c.id == cardId);

    if (index == -1) {
      return Result.failure(Exception('Không tìm thấy danh thiếp để xóa'));
    }

    final wasDefault = userCards[index].isDefault;
    userCards.removeAt(index);

    // Nếu vừa xóa thẻ mặc định và còn thẻ khác, chọn thẻ đầu tiên làm mặc định
    if (wasDefault && userCards.isNotEmpty) {
      userCards[0] = userCards[0].copyWith(isDefault: true);
    }

    _notify(userId);

    // Đồng bộ vào SQLite
    try {
      await DatabaseService.instance.deleteProfile(cardId);
    } catch (_) {}

    return Result.success(null);
  }

  @override
  Future<Result<BusinessCard>> duplicateCard({
    required String userId,
    required String cardId,
    required String newId,
  }) async {
    _ensureInitialized(userId);
    final userCards = _storage[userId]!;

    if (userCards.length >= CardConstants.maxCardsPerUser) {
      return Result.failure(
        Exception('Bạn đã đạt giới hạn tối đa ${CardConstants.maxCardsPerUser} danh thiếp.'),
      );
    }

    final original = userCards.firstWhere(
      (c) => c.id == cardId,
      orElse: () => throw Exception('Không tìm thấy danh thiếp nguồn'),
    );

    final now = DateTime.now();
    final clonedCard = original.copyWith(
      id: newId,
      cardName: '${original.cardName} (Bản sao)',
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    userCards.add(clonedCard);
    _notify(userId);

    // Đồng bộ vào SQLite
    try {
      await DatabaseService.instance.insertProfile(CardSyncMapper.toModel(clonedCard));
    } catch (_) {}

    return Result.success(clonedCard);
  }

  @override
  Future<Result<void>> setDefaultCard({
    required String userId,
    required String cardId,
  }) async {
    _ensureInitialized(userId);
    final userCards = _storage[userId]!;
    bool found = false;

    for (int i = 0; i < userCards.length; i++) {
      if (userCards[i].id == cardId) {
        userCards[i] = userCards[i].copyWith(isDefault: true);
        found = true;
      } else {
        userCards[i] = userCards[i].copyWith(isDefault: false);
      }
    }

    if (!found) {
      return Result.failure(Exception('Không tìm thấy danh thiếp'));
    }

    _notify(userId);

    // Đồng bộ vào SQLite
    try {
      await DatabaseService.instance.setDefaultProfile(cardId);
    } catch (_) {}

    return Result.success(null);
  }
}
