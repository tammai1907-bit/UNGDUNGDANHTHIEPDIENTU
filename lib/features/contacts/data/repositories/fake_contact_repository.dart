import 'dart:async';
import '../../domain/entities/saved_contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_seed_data.dart';

class FakeContactRepository implements ContactRepository {
  final Map<String, List<SavedContact>> _userContacts = {};
  final Map<String, Set<String>> _userCustomTags = {};
  final StreamController<List<SavedContact>> _contactsController =
      StreamController<List<SavedContact>>.broadcast();

  FakeContactRepository() {
    // Khởi tạo sẵn danh bạ cho user_current
    _userContacts['user_current'] = List.from(
      ContactSeedData.getInitialContacts('user_current'),
    );
    _userCustomTags['user_current'] = {
      'Tất cả',
      'Khách hàng',
      'Đồng nghiệp',
      'Sự kiện',
      'Đối tác',
      'VIP',
    };
  }

  void _ensureUserInitialized(String userId) {
    if (!_userContacts.containsKey(userId)) {
      _userContacts[userId] = List.from(ContactSeedData.getInitialContacts(userId));
    }
    if (!_userCustomTags.containsKey(userId)) {
      _userCustomTags[userId] = {
        'Tất cả',
        'Khách hàng',
        'Đồng nghiệp',
        'Sự kiện',
        'Đối tác',
        'VIP',
      };
    }
  }

  @override
  Stream<List<SavedContact>> watchContacts(String userId) {
    _ensureUserInitialized(userId);
    Future.microtask(() {
      _contactsController.add(List.unmodifiable(_userContacts[userId] ?? []));
    });
    return _contactsController.stream;
  }

  @override
  Future<List<SavedContact>> getContacts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _ensureUserInitialized(userId);
    return List.unmodifiable(_userContacts[userId] ?? []);
  }

  @override
  Future<SavedContact?> getContactById(String userId, String contactId) async {
    await Future.delayed(const Duration(milliseconds: 30));
    _ensureUserInitialized(userId);
    final list = _userContacts[userId] ?? [];
    try {
      return list.firstWhere((c) => c.id == contactId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveContact(String userId, SavedContact contact) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _ensureUserInitialized(userId);
    final list = _userContacts[userId]!;
    final index = list.indexWhere((c) => c.id == contact.id || (contact.originalCardId != null && c.originalCardId == contact.originalCardId));
    if (index >= 0) {
      list[index] = contact;
    } else {
      list.insert(0, contact);
    }

    // Tự động thêm các nhãn mới vào danh sách nhãn
    for (final tag in contact.tags) {
      _userCustomTags[userId]?.add(tag);
    }

    _contactsController.add(List.unmodifiable(list));
  }

  @override
  Future<void> updateContact(String userId, SavedContact contact) async {
    await saveContact(userId, contact);
  }

  @override
  Future<void> deleteContact(String userId, String contactId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    _ensureUserInitialized(userId);
    final list = _userContacts[userId]!;
    list.removeWhere((c) => c.id == contactId);
    _contactsController.add(List.unmodifiable(list));
  }

  @override
  Future<List<String>> getAvailableTags(String userId) async {
    _ensureUserInitialized(userId);
    final tagSet = <String>{'Tất cả', 'Khách hàng', 'Đồng nghiệp', 'Sự kiện', 'Đối tác', 'VIP'};
    tagSet.addAll(_userCustomTags[userId] ?? {});
    final list = _userContacts[userId] ?? [];
    for (final contact in list) {
      tagSet.addAll(contact.tags);
    }
    return tagSet.toList();
  }
}
