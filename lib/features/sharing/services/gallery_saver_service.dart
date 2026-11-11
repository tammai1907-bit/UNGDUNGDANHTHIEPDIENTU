import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Dịch vụ lưu ảnh trực tiếp vào Thư viện Ảnh (Photo/Gallery) của điện thoại.
class GallerySaverService {
  static const MethodChannel _channel = MethodChannel(
    'com.digitalbusinesscard.digital_business_card/gallery',
  );

  /// Cho phép giả lập hành vi lưu ảnh trong quá trình kiểm thử tự động
  @visibleForTesting
  static Future<String> Function(Uint8List bytes, String fileName)?
      saveImageOverride;

  /// Lưu mảng byte PNG vào thư viện Photo của thiết bị.
  /// Trả về đường dẫn/URI đã lưu nếu thành công.
  static Future<String> saveQrImage(
    Uint8List bytes, {
    required String fileName,
  }) async {
    if (saveImageOverride != null) {
      return saveImageOverride!(bytes, fileName);
    }
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (Platform.isIOS) {
        await Permission.photosAddOnly.request();
      } else if (Platform.isAndroid) {
        // Android <= 9 cần quyền storage; Android 10+ dùng Scoped Storage MediaStore
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          await Permission.storage.request();
        }
      }

      final result = await _channel.invokeMethod<String>('saveImage', {
        'bytes': bytes,
        'fileName': fileName,
      });

      if (result != null && result.isNotEmpty) {
        return result;
      }
      throw Exception('Không thể lưu ảnh vào thư viện ảnh');
    }

    // Fallback cho desktop hoặc môi trường khác
    final docsDir = await getApplicationDocumentsDirectory();
    final file = File('${docsDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
