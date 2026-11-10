import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/core/utils/result.dart';
import 'package:digital_business_card/features/auth/presentation/providers/auth_providers.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart'
    show useMockDataProvider;
import 'package:digital_business_card/features/contacts/domain/entities/saved_contact.dart';
import 'package:digital_business_card/features/contacts/domain/repositories/contact_repository.dart';
import 'package:digital_business_card/features/contacts/data/repositories/fake_contact_repository.dart';
import 'package:digital_business_card/features/contacts/data/repositories/firebase_contact_repository.dart';
import 'package:digital_business_card/features/contacts/utils/vietnamese_search_helper.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  if (useMock) {
    return FakeContactRepository();
  }
  return FirebaseContactRepository();
});

final contactsStreamProvider = StreamProvider<List<SavedContact>>((ref) {
  final repo = ref.watch(contactRepositoryProvider);
  final user = ref.watch(currentUserProfileProvider);
  final userId = user?.id ?? 'user_current';
  return repo.watchContacts(userId);
});

final contactSearchQueryProvider = StateProvider<String>((ref) => '');

final selectedTagFilterProvider = StateProvider<String>((ref) => 'Tất cả');

final userCustomTagsProvider = StateProvider<List<String>>((ref) => []);

/// Danh mục tất cả các nhãn phân loại (kết hợp các nhãn mặc định + nhãn tùy chỉnh người dùng tạo ra)
final availableTagsProvider = Provider<List<String>>((ref) {
  final contactsAsync = ref.watch(contactsStreamProvider);
  final customTags = ref.watch(userCustomTagsProvider);

  final tagSet = <String>{
    'Tất cả',
    'Khách hàng',
    'Đồng nghiệp',
    'Sự kiện',
    'Đối tác',
    'VIP',
  };

  tagSet.addAll(customTags);

  contactsAsync.whenData((contacts) {
    for (final c in contacts) {
      tagSet.addAll(c.tags);
    }
  });

  return tagSet.toList();
});

/// Danh sách liên hệ đã được lọc theo từ khóa tìm kiếm (tiếng Việt không dấu) và Tag
final filteredContactsProvider = Provider<AsyncValue<List<SavedContact>>>((
  ref,
) {
  final contactsAsync = ref.watch(contactsStreamProvider);
  final query = ref.watch(contactSearchQueryProvider).trim();
  final selectedTag = ref.watch(selectedTagFilterProvider);

  return contactsAsync.whenData((contacts) {
    return contacts.where((contact) {
      // 1. Lọc theo Tag phân loại
      if (selectedTag != 'Tất cả' && !contact.tags.contains(selectedTag)) {
        return false;
      }

      // 2. Lọc theo từ khóa tìm kiếm thông minh tiếng Việt (tên, công ty, chức danh, sđt, email, ghi chú, nhãn)
      if (query.isNotEmpty) {
        final matchName = VietnameseSearchHelper.matches(
          contact.fullName,
          query,
        );
        final matchCompany =
            contact.company != null &&
            VietnameseSearchHelper.matches(contact.company!, query);
        final matchJob =
            contact.jobTitle != null &&
            VietnameseSearchHelper.matches(contact.jobTitle!, query);
        final matchPhone =
            contact.phone != null && contact.phone!.contains(query);
        final matchEmail =
            contact.email != null &&
            VietnameseSearchHelper.matches(contact.email!, query);
        final matchNotes =
            contact.notes != null &&
            VietnameseSearchHelper.matches(contact.notes!, query);
        final matchLocation =
            contact.savedLocation != null &&
            VietnameseSearchHelper.matches(contact.savedLocation!, query);
        final matchTags = contact.tags.any(
          (t) => VietnameseSearchHelper.matches(t, query),
        );

        if (!matchName &&
            !matchCompany &&
            !matchJob &&
            !matchPhone &&
            !matchEmail &&
            !matchNotes &&
            !matchLocation &&
            !matchTags) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});

/// Controller xử lý thao tác Thêm, Sửa, Xóa danh bạ trong Ví
class ContactController extends StateNotifier<AsyncValue<void>> {
  final ContactRepository _repository;
  final String _userId;

  ContactController(this._repository, this._userId)
    : super(const AsyncValue.data(null));

  Future<Result<void>> addContact(SavedContact contact) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveContact(
        _userId,
        contact.copyWith(ownerId: _userId),
      );
      state = const AsyncValue.data(null);
      return Result.success(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Result.failure(e);
    }
  }

  Future<Result<void>> updateContact(SavedContact contact) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateContact(
        _userId,
        contact.copyWith(ownerId: _userId),
      );
      state = const AsyncValue.data(null);
      return Result.success(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Result.failure(e);
    }
  }

  Future<Result<void>> deleteContact(String contactId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteContact(_userId, contactId);
      state = const AsyncValue.data(null);
      return Result.success(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Result.failure(e);
    }
  }
}

final contactControllerProvider =
    StateNotifierProvider<ContactController, AsyncValue<void>>((ref) {
      final repo = ref.watch(contactRepositoryProvider);
      final user = ref.watch(currentUserProfileProvider);
      return ContactController(repo, user?.id ?? 'user_current');
    });

/// Provider kiểm tra nhanh xem danh thiếp cụ thể (theo originalCardId) đã được lưu vào ví hay chưa
final isCardSavedInWalletProvider = Provider.family<bool, String>((
  ref,
  cardId,
) {
  if (cardId.isEmpty) return false;
  final contactsAsync = ref.watch(contactsStreamProvider);
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts.any((c) => c.originalCardId == cardId),
    orElse: () => false,
  );
});
