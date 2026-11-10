import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/card_design/domain/entities/card_design.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
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

    test('Chuyển đổi từ BusinessCard sang SavedContact thành công', () {
      final card = BusinessCard(
        id: 'card_partner_01',
        ownerId: 'partner_user',
        cardName: 'Thẻ Đối Tác',
        fullName: 'Lê Hoàng Nam',
        jobTitle: 'Product Lead',
        company: 'VinTech',
        design: CardDesign.initial(),
        phone: '0912345678',
        email: 'nam.le@vintech.com',
        website: 'https://vintech.com',
        address: 'Hà Nội',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final contact = SavedContact.fromBusinessCard(
        card,
        tags: ['Đối tác', 'Sự kiện'],
        notes: 'Gặp tại sự kiện Tech Expo 2026',
        source: 'Quét mã QR',
      );

      expect(contact.fullName, 'Lê Hoàng Nam');
      expect(contact.originalCardId, 'card_partner_01');
      expect(contact.tags, contains('Sự kiện'));
      expect(contact.notes, 'Gặp tại sự kiện Tech Expo 2026');
      expect(contact.source, 'Quét mã QR');
    });

    test('Phân tích chuỗi vCard thô sang SavedContact thành công', () {
      const vcard = '''BEGIN:VCARD
VERSION:3.0
FN:Trần Thị Mai
ORG:Tập đoàn Viettel
TITLE:Chuyên gia Bảo mật
TEL:0988776655
EMAIL:mai.tran@viettel.com.vn
NOTE:Gặp gỡ tại Hội thảo An ninh mạng 2026
END:VCARD''';

      final contact = SavedContact.fromVCard(
        vcard,
        source: 'Quét mã QR',
        tags: ['Khách hàng', 'Sự kiện'],
      );

      expect(contact.fullName, 'Trần Thị Mai');
      expect(contact.company, 'Tập đoàn Viettel');
      expect(contact.jobTitle, 'Chuyên gia Bảo mật');
      expect(contact.phone, '0988776655');
      expect(contact.email, 'mai.tran@viettel.com.vn');
      expect(contact.notes, 'Gặp gỡ tại Hội thảo An ninh mạng 2026');
      expect(contact.tags, contains('Khách hàng'));
    });
  });
}
