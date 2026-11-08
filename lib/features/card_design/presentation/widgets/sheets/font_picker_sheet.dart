import 'package:flutter/material.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';

/// Bottom sheet chọn phông chữ tiếng Việt với xem trước thời gian thực
class FontPickerSheet extends StatelessWidget {
  final String currentFontFamily;
  final ValueChanged<String> onFontSelected;

  const FontPickerSheet({
    super.key,
    required this.currentFontFamily,
    required this.onFontSelected,
  });

  static Future<String?> show({
    required BuildContext context,
    required String currentFontFamily,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => FontPickerSheet(
          currentFontFamily: currentFontFamily,
          onFontSelected: (font) => Navigator.pop(ctx, font),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh kéo
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Tiêu đề
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.font_download_rounded, color: Color(0xFF1E88E5)),
              SizedBox(width: 10),
              Text(
                'Chọn Phông Chữ (Google Fonts)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const Divider(height: 16),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: CardConstants.supportedFonts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final fontName = CardConstants.supportedFonts[index];
              final isSelected = fontName.toLowerCase() == currentFontFamily.toLowerCase();
              final fontStyle = CardConstants.getFontStyle(fontName);

              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: isSelected,
                selectedTileColor: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                title: Text(
                  fontName,
                  style: fontStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Mai Văn Tâm — Kỹ sư Phần mềm Cấp cao',
                    style: fontStyle.copyWith(
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade700,
                    ),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1E88E5))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () => onFontSelected(fontName),
              );
            },
          ),
        ),
      ],
    );
  }
}
