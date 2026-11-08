import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/card_design/data/repositories/fake_card_repository.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';

void main() {
  group('FakeCardRepository Tests', () {
    late FakeCardRepository repo;
    const testUserId = 'test_user_01';

    setUp(() {
      repo = FakeCardRepository();
    });

    test('Initial cards are loaded correctly for Mai Văn Tâm', () async {
      final res = await repo.getCards(testUserId);
      expect(res.isSuccess, isTrue);
      final cards = res.dataOrNull!;
      expect(cards.length, equals(2));
      expect(cards.first.fullName, equals('Mai Văn Tâm'));
      expect(cards.first.isDefault, isTrue);
    });

    test('Create card succeeds within limit', () async {
      final newCard = BusinessCard.empty(
        id: 'new_card_1',
        ownerId: testUserId,
        cardName: 'Thẻ Nghiên Cứu',
        fullName: 'Mai Văn Tâm',
      );

      final res = await repo.createCard(newCard);
      expect(res.isSuccess, isTrue);

      final listRes = await repo.getCards(testUserId);
      expect(listRes.dataOrNull!.length, equals(3));
    });

    test('Enforces max 5 cards per user', () async {
      // Add cards until reaching 5
      await repo.createCard(BusinessCard.empty(id: 'c3', ownerId: testUserId));
      await repo.createCard(BusinessCard.empty(id: 'c4', ownerId: testUserId));
      await repo.createCard(BusinessCard.empty(id: 'c5', ownerId: testUserId));

      final countRes = await repo.getCards(testUserId);
      expect(countRes.dataOrNull!.length, equals(5));

      // Attempting 6th card must fail
      final failRes = await repo.createCard(
        BusinessCard.empty(id: 'c6', ownerId: testUserId),
      );
      expect(failRes.isSuccess, isFalse);
    });

    test('Duplicate card duplicates correctly', () async {
      final dupRes = await repo.duplicateCard(
        userId: testUserId,
        cardId: 'card_official_01',
        newId: 'cloned_id',
      );

      expect(dupRes.isSuccess, isTrue);
      expect(dupRes.dataOrNull!.cardName, contains('Bản sao'));
      expect(dupRes.dataOrNull!.isDefault, isFalse);
    });

    test('Set default card updates correctly', () async {
      final res = await repo.setDefaultCard(
        userId: testUserId,
        cardId: 'card_freelance_02',
      );
      expect(res.isSuccess, isTrue);

      final list = (await repo.getCards(testUserId)).dataOrNull!;
      final freelance = list.firstWhere((c) => c.id == 'card_freelance_02');
      final official = list.firstWhere((c) => c.id == 'card_official_01');

      expect(freelance.isDefault, isTrue);
      expect(official.isDefault, isFalse);
    });

    test('Delete card removes it and updates default if needed', () async {
      final delRes = await repo.deleteCard(
        userId: testUserId,
        cardId: 'card_official_01',
      );
      expect(delRes.isSuccess, isTrue);

      final list = (await repo.getCards(testUserId)).dataOrNull!;
      expect(list.length, equals(1));
      expect(list.first.isDefault, isTrue);
    });
  });
}
