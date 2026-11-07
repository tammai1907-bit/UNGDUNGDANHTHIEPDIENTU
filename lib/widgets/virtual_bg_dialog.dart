import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../models/business_card_model.dart';
import '../services/share_service.dart';

class VirtualBgDialog extends StatefulWidget {
  final BusinessCardModel card;

  const VirtualBgDialog({super.key, required this.card});

  @override
  State<VirtualBgDialog> createState() => _VirtualBgDialogState();
}

class _VirtualBgDialogState extends State<VirtualBgDialog> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _selectedBgStyle = 0; // 0: Office Gradient, 1: Modern Dark, 2: Luxury Gold

  final List<Map<String, dynamic>> _bgStyles = [
    {
      'name': 'Corporate Blue',
      'colors': [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF0284C7)],
      'accent': Color(0xFF38BDF8),
    },
    {
      'name': 'Minimal Dark',
      'colors': [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF3F3F46)],
      'accent': Color(0xFFE4E4E7),
    },
    {
      'name': 'Executive Gold',
      'colors': [Color(0xFF1C1917), Color(0xFF44403C), Color(0xFF78350F)],
      'accent': Color(0xFFFBBF24),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final style = _bgStyles[_selectedBgStyle];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Phông Nền Ảo Zoom / Meet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const Text(
                'Hình nền chuẩn tỉ lệ 16:9 tích hợp mã QR danh thiếp để mọi người quét trực tiếp trong cuộc họp.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              // Chọn kiểu phông nền
              Row(
                children: List.generate(_bgStyles.length, (index) {
                  final isSelected = _selectedBgStyle == index;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(_bgStyles[index]['name'], style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedBgStyle = index);
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Preview phông nền 16:9 với ScreenshotController
              Center(
                child: Screenshot(
                  controller: _screenshotController,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: style['colors'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left side: User information
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.card.company.toUpperCase(),
                                  style: TextStyle(
                                    color: style['accent'] as Color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.card.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  widget.card.jobTitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right side: QR Code
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                QrImageView(
                                  data: widget.card.toVCard(),
                                  version: QrVersions.auto,
                                  size: 64,
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'QUÉT KẾT NỐI',
                                  style: TextStyle(
                                    fontSize: 6,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Button Chia sẻ / Tải ảnh
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ShareService.instance.captureAndShareCardImage(
                      _screenshotController,
                      'Virtual_Background_${widget.card.fullName}',
                    );
                  },
                  icon: const Icon(Icons.download_for_offline, size: 20),
                  label: const Text('Xuất & Lưu Phông Nền 16:9'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
