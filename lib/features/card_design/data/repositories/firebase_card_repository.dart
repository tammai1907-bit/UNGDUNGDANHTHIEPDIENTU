import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/card_constants.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/business_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../models/business_card_model.dart';

/// Bản cài đặt Firebase Cloud Firestore cho CardRepository
class FirebaseCardRepository implements CardRepository {
  final FirebaseFirestore _firestore;

  FirebaseCardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cardsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cards');
  }

  @override
  Stream<List<BusinessCard>> watchCards(String userId) {
    return _cardsCollection(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BusinessCardModelMapper.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  @override
  Future<Result<List<BusinessCard>>> getCards(String userId) async {
    try {
      final snapshot = await _cardsCollection(userId)
          .orderBy('createdAt', descending: false)
          .get();

      final cards = snapshot.docs.map((doc) {
        return BusinessCardModelMapper.fromMap(doc.data(), docId: doc.id);
      }).toList();

      return Result.success(cards);
    } catch (e) {
      return Result.failure(Exception('Lỗi tải danh thiếp: $e'));
    }
  }

  @override
  Future<Result<BusinessCard>> getCardById({
    required String userId,
    required String cardId,
  }) async {
    try {
      final doc = await _cardsCollection(userId).doc(cardId).get();
      if (!doc.exists || doc.data() == null) {
        return Result.failure(Exception('Không tìm thấy danh thiếp'));
      }
      return Result.success(
        BusinessCardModelMapper.fromMap(doc.data()!, docId: doc.id),
      );
    } catch (e) {
      return Result.failure(Exception('Lỗi đọc chi tiết danh thiếp: $e'));
    }
  }

  @override
  Future<Result<void>> createCard(BusinessCard card) async {
    try {
      final col = _cardsCollection(card.ownerId);
      final countSnap = await col.count().get();
      if ((countSnap.count ?? 0) >= CardConstants.maxCardsPerUser) {
        return Result.failure(
          Exception('Bạn đã đạt giới hạn tối đa ${CardConstants.maxCardsPerUser} danh thiếp.'),
        );
      }

      final batch = _firestore.batch();
      if (card.isDefault || (countSnap.count ?? 0) == 0) {
        final existingDocs = await col.where('isDefault', isEqualTo: true).get();
        for (final d in existingDocs.docs) {
          batch.update(d.reference, {'isDefault': false});
        }
      }

      final newDocRef = col.doc(card.id);
      batch.set(newDocRef, card.toMap());
      await batch.commit();

      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Lỗi tạo danh thiếp: $e'));
    }
  }

  @override
  Future<Result<void>> updateCard(BusinessCard card) async {
    try {
      final col = _cardsCollection(card.ownerId);
      final batch = _firestore.batch();

      if (card.isDefault) {
        final existingDocs = await col.where('isDefault', isEqualTo: true).get();
        for (final d in existingDocs.docs) {
          if (d.id != card.id) {
            batch.update(d.reference, {'isDefault': false});
          }
        }
      }

      final docRef = col.doc(card.id);
      batch.update(docRef, card.toMap());
      await batch.commit();

      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Lỗi cập nhật danh thiếp: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCard({
    required String userId,
    required String cardId,
  }) async {
    try {
      final col = _cardsCollection(userId);
      final targetDoc = await col.doc(cardId).get();
      if (!targetDoc.exists) {
        return Result.failure(Exception('Không tìm thấy danh thiếp để xóa'));
      }

      final wasDefault = targetDoc.data()?['isDefault'] as bool? ?? false;
      await col.doc(cardId).delete();

      // Nếu xóa thẻ mặc định, tìm thẻ còn lại để đặt làm mặc định
      if (wasDefault) {
        final remaining = await col.limit(1).get();
        if (remaining.docs.isNotEmpty) {
          await remaining.docs.first.reference.update({'isDefault': true});
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Lỗi xóa danh thiếp: $e'));
    }
  }

  @override
  Future<Result<BusinessCard>> duplicateCard({
    required String userId,
    required String cardId,
    required String newId,
  }) async {
    try {
      final col = _cardsCollection(userId);
      final countSnap = await col.count().get();
      if ((countSnap.count ?? 0) >= CardConstants.maxCardsPerUser) {
        return Result.failure(
          Exception('Bạn đã đạt giới hạn tối đa ${CardConstants.maxCardsPerUser} danh thiếp.'),
        );
      }

      final originalDoc = await col.doc(cardId).get();
      if (!originalDoc.exists || originalDoc.data() == null) {
        return Result.failure(Exception('Không tìm thấy danh thiếp nguồn'));
      }

      final original = BusinessCardModelMapper.fromMap(
        originalDoc.data()!,
        docId: originalDoc.id,
      );

      final now = DateTime.now();
      final cloned = original.copyWith(
        id: newId,
        cardName: '${original.cardName} (Bản sao)',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      await col.doc(newId).set(cloned.toMap());
      return Result.success(cloned);
    } catch (e) {
      return Result.failure(Exception('Lỗi nhân bản danh thiếp: $e'));
    }
  }

  @override
  Future<Result<void>> setDefaultCard({
    required String userId,
    required String cardId,
  }) async {
    try {
      final col = _cardsCollection(userId);
      final allDocs = await col.get();
      final batch = _firestore.batch();

      for (final doc in allDocs.docs) {
        final isTarget = doc.id == cardId;
        batch.update(doc.reference, {'isDefault': isTarget});
      }

      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Lỗi đặt danh thiếp mặc định: $e'));
    }
  }
}
