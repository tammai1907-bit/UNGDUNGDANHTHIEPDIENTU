import '../../../../core/utils/result.dart';

/// Interface quản lý tải ảnh lên đám mây và xóa ảnh
abstract class StorageRepository {
  /// Tải tệp ảnh cục bộ lên (avatar hoặc banner) và trả về URL công khai
  Future<Result<String>> uploadImage({
    required String userId,
    required String cardId,
    required String localFilePath,
    required String slotName, // 'avatar' hoặc 'banner'
  });

  /// Xóa ảnh từ Cloud Storage khi người dùng đổi hoặc gỡ ảnh
  Future<Result<void>> deleteImage(String imageUrl);
}
