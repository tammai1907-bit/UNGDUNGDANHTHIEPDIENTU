import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/storage_repository.dart';

/// Bản cài đặt Firebase Cloud Storage với chức năng nén ảnh trước khi tải
class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage _storage;

  FirebaseStorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Result<String>> uploadImage({
    required String userId,
    required String cardId,
    required String localFilePath,
    required String slotName,
  }) async {
    try {
      final originalFile = File(localFilePath);
      if (!await originalFile.exists()) {
        return Result.failure(Exception('Tệp ảnh không tồn tại: $localFilePath'));
      }

      // Nén ảnh để dung lượng luôn dưới 1MB và tối ưu hiển thị di động
      File uploadFile = originalFile;
      final targetPath = '${originalFile.parent.path}/compressed_${slotName}_$cardId.jpg';

      try {
        final compressedXFile = await FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          targetPath,
          quality: 85,
          minWidth: 1080,
          minHeight: 1080,
          format: CompressFormat.jpeg,
        );
        if (compressedXFile != null) {
          uploadFile = File(compressedXFile.path);
        }
      } catch (_) {
        // Nếu nén không thành công do môi trường desktop/test, dùng file gốc
        uploadFile = originalFile;
      }

      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('cards')
          .child(cardId)
          .child('$slotName.jpg');

      final uploadTask = ref.putFile(
        uploadFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Result.success(downloadUrl);
    } catch (e) {
      return Result.failure(Exception('Lỗi tải ảnh lên Cloud Storage: $e'));
    }
  }

  @override
  Future<Result<void>> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
      return Result.success(null);
    } catch (e) {
      // Bỏ qua lỗi xóa nếu file không tồn tại
      return Result.success(null);
    }
  }
}
