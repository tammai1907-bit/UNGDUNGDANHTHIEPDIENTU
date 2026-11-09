import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/contacts/data/repositories/fake_contact_repository.dart';
import 'package:digital_business_card/features/contacts/domain/entities/saved_contact.dart';

void main() {
  group('FakeContactRepository Tests', () {
    late FakeContactRepository repository;
    const userId = 'user_test';

    setUp(() {
      repository = FakeContactRepository();
    });

    test('Lấy danh bạ khởi tạo có sẵn 3 liên hệ mẫu', () async {
      final contacts = await repository.getContacts(userId);
      expect(contacts.length, 3);
      expect(contacts.any((c) => c.fullName == 'Nguyễn Thị Lan'), isTrue);
    });

    test('Thêm danh bạ mới thành công', () async {
      final newContact = SavedContact(
        id: 'contact_new',
        ownerId: userId,
        fullName: 'Phạm Đức Anh',
        company: 'VNG Corporation',
        phone: '0977112233',
        tags: const ['Khách hàng'],
        savedAt: DateTime.now(),
      );

      await repository.saveContact(userId, newContact);

      final contacts = await repository.getContacts(userId);
      expect(contacts.length, 4);
      expect(contacts.first.fullName, 'Phạm Đức Anh');
    });

    test('Cập nhật ghi chú và tag cho liên hệ', () async {
      final initial = await repository.getContactById(userId, 'contact_01');
      expect(initial, isNotNull);

      final updated = initial!.copyWith(
        notes: 'Ghi chú mới đã được cập nhật',
        tags: ['Khách hàng', 'VIP', 'Chiến lược'],
      );

      await repository.updateContact(userId, updated);

      final fetched = await repository.getContactById(userId, 'contact_01');
      expect(fetched?.notes, 'Ghi chú mới đã được cập nhật');
      expect(fetched?.tags.contains('Chiến lược'), isTrue);
    });

    test('Xóa liên hệ khỏi danh bạ', () async {
      await repository.deleteContact(userId, 'contact_01');

      final contacts = await repository.getContacts(userId);
      expect(contacts.any((c) => c.id == 'contact_01'), isFalse);
    });
  });
}
