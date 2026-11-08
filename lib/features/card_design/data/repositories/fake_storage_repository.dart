import '../../../../core/utils/result.dart';
import '../../domain/repositories/storage_repository.dart';

/// Bản cài đặt Fake của StorageRepository để chạy offline/mock
class FakeStorageRepository implements StorageRepository {
  @override
  Future<Result<String>> uploadImage({
    required String userId,
    required String cardId,
    required String localFilePath,
    required String slotName,
  }) async {
    // Giả lập thời gian nén và upload lên mạng
    await Future.delayed(const Duration(milliseconds: 400));
    // Trong môi trường mock, trả về trực tiếp đường dẫn file cục bộ để widget hiển thị ngay
    return Result.success(localFilePath);
  }

  @override
  Future<Result<void>> deleteImage(String imageUrl) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Result.success(null);
  }
}
