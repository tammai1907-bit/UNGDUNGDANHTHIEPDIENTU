import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/business_card.dart';
import '../../domain/entities/card_design.dart';
import '../../domain/entities/social_link.dart';
import 'card_repository_provider.dart';
import 'current_user_provider.dart';

/// Trạng thái của màn hình Chỉnh sửa / Tạo danh thiếp
class CardEditorState {
  final BusinessCard card;
  final BusinessCard initialCard;
  final bool isNew;
  final String? localAvatarPath;
  final String? localBannerPath;
  final bool isSaving;
  final String? errorMessage;
  final bool saveSuccess;

  const CardEditorState({
    required this.card,
    required this.initialCard,
    required this.isNew,
    this.localAvatarPath,
    this.localBannerPath,
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  /// Kiểm tra xem người dùng đã thay đổi dữ liệu nào so với ban đầu chưa
  bool get isDirty {
    return card != initialCard ||
        localAvatarPath != null ||
        localBannerPath != null;
  }

  CardEditorState copyWith({
    BusinessCard? card,
    BusinessCard? initialCard,
    bool? isNew,
    String? localAvatarPath,
    bool clearLocalAvatar = false,
    String? localBannerPath,
    bool clearLocalBanner = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool? saveSuccess,
  }) {
    return CardEditorState(
      card: card ?? this.card,
      initialCard: initialCard ?? this.initialCard,
      isNew: isNew ?? this.isNew,
      localAvatarPath: clearLocalAvatar ? null : (localAvatarPath ?? this.localAvatarPath),
      localBannerPath: clearLocalBanner ? null : (localBannerPath ?? this.localBannerPath),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

/// Controller quản lý chỉnh sửa và Live Preview theo thời gian thực
class CardEditorController extends StateNotifier<CardEditorState> {
  final Ref _ref;

  CardEditorController(this._ref, BusinessCard? initialCard)
      : super(_initState(_ref, initialCard));

  static CardEditorState _initState(Ref ref, BusinessCard? initialCard) {
    final userId = ref.read(currentUserIdProvider);
    final isNew = initialCard == null;

    final card = initialCard ??
        BusinessCard.empty(
          id: const Uuid().v4(),
          ownerId: userId,
          cardName: 'Danh thiếp của tôi',
          fullName: 'Mai Văn Tâm',
        );

    return CardEditorState(
      card: card,
      initialCard: card,
      isNew: isNew,
    );
  }

  /// Cập nhật thông tin cơ bản (Live Preview cập nhật ngay lập tức)
  void updateBasicInfo({
    String? cardName,
    String? fullName,
    String? jobTitle,
    String? company,
    String? bio,
    String? phone,
    String? email,
    String? website,
    String? address,
  }) {
    state = state.copyWith(
      card: state.card.copyWith(
        cardName: cardName,
        fullName: fullName,
        jobTitle: jobTitle,
        company: company,
        bio: bio,
        phone: phone,
        email: email,
        website: website,
        address: address,
      ),
      clearError: true,
    );
  }

  /// Cập nhật thiết kế (Template, Màu sắc, Phông chữ, Bo góc, Banner)
  void updateDesign(CardDesign design) {
    state = state.copyWith(
      card: state.card.copyWith(design: design),
      clearError: true,
    );
  }

  /// Chọn ảnh đại diện từ máy ảnh hoặc thư viện
  void setAvatarLocal(String path) {
    state = state.copyWith(
      localAvatarPath: path,
      card: state.card.copyWith(avatarUrl: path),
      clearError: true,
    );
  }

  /// Gỡ bỏ ảnh đại diện
  void removeAvatar() {
    state = state.copyWith(
      clearLocalAvatar: true,
      card: state.card.copyWith(avatarUrl: null),
      clearError: true,
    );
  }

  /// Chọn ảnh bìa (banner)
  void setBannerLocal(String path) {
    state = state.copyWith(
      localBannerPath: path,
      card: state.card.copyWith(bannerUrl: path),
      clearError: true,
    );
  }

  /// Gỡ bỏ ảnh bìa
  void removeBanner() {
    state = state.copyWith(
      clearLocalBanner: true,
      card: state.card.copyWith(bannerUrl: null),
      clearError: true,
    );
  }

  /// Thêm liên kết mạng xã hội
  void addSocialLink(SocialLink link) {
    final currentLinks = List<SocialLink>.from(state.card.socialLinks);
    final newLink = link.copyWith(order: currentLinks.length);
    currentLinks.add(newLink);

    state = state.copyWith(
      card: state.card.copyWith(socialLinks: currentLinks),
      clearError: true,
    );
  }

  /// Cập nhật liên kết mạng xã hội
  void updateSocialLink(SocialLink updatedLink) {
    final currentLinks = List<SocialLink>.from(state.card.socialLinks);
    final index = currentLinks.indexWhere((l) => l.id == updatedLink.id);
    if (index != -1) {
      currentLinks[index] = updatedLink;
      state = state.copyWith(
        card: state.card.copyWith(socialLinks: currentLinks),
        clearError: true,
      );
    }
  }

  /// Xóa liên kết mạng xã hội
  void removeSocialLink(String linkId) {
    final currentLinks = List<SocialLink>.from(state.card.socialLinks)
      ..removeWhere((l) => l.id == linkId);

    // Chuẩn hóa lại thứ tự order
    for (int i = 0; i < currentLinks.length; i++) {
      currentLinks[i] = currentLinks[i].copyWith(order: i);
    }

    state = state.copyWith(
      card: state.card.copyWith(socialLinks: currentLinks),
      clearError: true,
    );
  }

  /// Sắp xếp lại thứ tự danh sách liên kết kéo-thả (Reorderable)
  void reorderSocialLinks(int oldIndex, int newIndex) {
    final currentLinks = List<SocialLink>.from(state.card.socialLinks);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = currentLinks.removeAt(oldIndex);
    currentLinks.insert(newIndex, item);

    // Cập nhật lại thuộc tính order
    for (int i = 0; i < currentLinks.length; i++) {
      currentLinks[i] = currentLinks[i].copyWith(order: i);
    }

    state = state.copyWith(
      card: state.card.copyWith(socialLinks: currentLinks),
      clearError: true,
    );
  }

  /// Lưu danh thiếp (Upload ảnh nếu có, ghi Firestore hoặc FakeRepo)
  Future<bool> saveCard() async {
    final trimmedName = state.card.fullName.trim();
    final trimmedCardName = state.card.cardName.trim();

    if (trimmedCardName.isEmpty) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Vui lòng nhập Tên danh thiếp',
      );
      return false;
    }

    if (trimmedName.isEmpty) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Vui lòng nhập Họ và tên đầy đủ',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    final cardRepo = _ref.read(cardRepositoryProvider);
    final storageRepo = _ref.read(storageRepositoryProvider);
    final userId = _ref.read(currentUserIdProvider);

    String? finalAvatarUrl = state.card.avatarUrl;
    String? finalBannerUrl = state.card.bannerUrl;

    // 1. Tải Avatar lên nếu người dùng vừa chọn ảnh mới từ máy
    if (state.localAvatarPath != null) {
      final uploadRes = await storageRepo.uploadImage(
        userId: userId,
        cardId: state.card.id,
        localFilePath: state.localAvatarPath!,
        slotName: 'avatar',
      );

      final uploadResult = uploadRes.when(
        success: (url) {
          finalAvatarUrl = url;
          return true;
        },
        failure: (err) {
          state = state.copyWith(
            isSaving: false,
            errorMessage: 'Lỗi tải ảnh đại diện: ${err.toString()}',
          );
          return false;
        },
      );

      if (!uploadResult) return false;
    }

    // 2. Tải Banner lên nếu vừa chọn banner mới
    if (state.localBannerPath != null) {
      final uploadRes = await storageRepo.uploadImage(
        userId: userId,
        cardId: state.card.id,
        localFilePath: state.localBannerPath!,
        slotName: 'banner',
      );

      final uploadResult = uploadRes.when(
        success: (url) {
          finalBannerUrl = url;
          return true;
        },
        failure: (err) {
          state = state.copyWith(
            isSaving: false,
            errorMessage: 'Lỗi tải ảnh bìa: ${err.toString()}',
          );
          return false;
        },
      );

      if (!uploadResult) return false;
    }

    final cardToSave = state.card.copyWith(
      avatarUrl: finalAvatarUrl,
      bannerUrl: finalBannerUrl,
      updatedAt: DateTime.now(),
    );

    // 3. Tạo mới hoặc Cập nhật vào Repository
    final saveRes = state.isNew
        ? await cardRepo.createCard(cardToSave)
        : await cardRepo.updateCard(cardToSave);

    return saveRes.when(
      success: (_) {
        state = state.copyWith(
          isSaving: false,
          saveSuccess: true,
          card: cardToSave,
          initialCard: cardToSave,
          clearLocalAvatar: true,
          clearLocalBanner: true,
        );
        return true;
      },
      failure: (err) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: err.toString(),
        );
        return false;
      },
    );
  }
}

final cardEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<CardEditorController, CardEditorState, BusinessCard?>((ref, card) {
  return CardEditorController(ref, card);
});
