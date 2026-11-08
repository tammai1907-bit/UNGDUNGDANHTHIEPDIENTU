import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

enum ImageCropType { square, banner }

/// Widget chọn, cắt (cropper) và xem trước ảnh đại diện hoặc ảnh bìa
class ImageUploadField extends StatelessWidget {
  final String label;
  final String? currentImageUrl;
  final ImageCropType cropType;
  final void Function(String localPath) onImageSelected;
  final VoidCallback? onImageRemoved;

  const ImageUploadField({
    super.key,
    required this.label,
    required this.currentImageUrl,
    required this.cropType,
    required this.onImageSelected,
    this.onImageRemoved,
  });

  Future<void> _pickAndCrop(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (pickedFile == null) return;

    // Cắt ảnh theo tỉ lệ
    final isSquare = cropType == ImageCropType.square;
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: isSquare
            ? const CropAspectRatio(ratioX: 1, ratioY: 1)
            : const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: isSquare ? 'Cắt ảnh đại diện (1:1)' : 'Cắt ảnh bìa (16:9)',
            toolbarColor: const Color(0xFF1E88E5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isSquare
                ? CropAspectRatioPreset.square
                : CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: isSquare ? 'Cắt ảnh đại diện' : 'Cắt ảnh bìa',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        onImageSelected(croppedFile.path);
      }
    } catch (_) {
      // Nếu ImageCropper gặp lỗi môi trường desktop, dùng trực tiếp pickedFile
      onImageSelected(pickedFile.path);
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn $label',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1E88E5)),
                  title: const Text('Chọn từ Thư viện ảnh'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndCrop(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1E88E5)),
                  title: const Text('Chụp ảnh mới bằng Máy ảnh'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndCrop(context, ImageSource.camera);
                  },
                ),
                if (currentImageUrl != null && onImageRemoved != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    title: const Text('Gỡ bỏ ảnh hiện tại', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onImageRemoved!();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = currentImageUrl != null && currentImageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showSourceSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: cropType == ImageCropType.square ? 100 : 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImagePreview(currentImageUrl!),
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Đổi ảnh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cropType == ImageCropType.square
                              ? Icons.account_circle_outlined
                              : Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tải lên $label',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(color: Colors.grey.shade300);
  }
}
