import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_editor_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/templates/template_registry.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/sheets/color_picker_sheet.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/sheets/font_picker_sheet.dart';

/// Tab 2: Tùy biến giao diện (Template, Màu sắc, Phông chữ, Bo góc)
class CardDesignTab extends ConsumerWidget {
  final BusinessCard? card;

  const CardDesignTab({super.key, this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(cardEditorControllerProvider(card));
    final currentCard = editorState.card;
    final d = currentCard.design;
    final controller = ref.read(cardEditorControllerProvider(card).notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // 1. Chọn Mẫu thiết kế (Template)
        const Text(
          'Chọn mẫu thiết kế (Template)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...TemplateRegistry.getAll().map((template) {
          final isSelected = d.templateId == template.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {
                controller.updateDesign(d.copyWith(templateId: template.id));
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E88E5).withValues(alpha: 0.08)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E88E5)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        template.icon,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF1E88E5) : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            template.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF1E88E5))
                    else
                      const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // 2. Bảng màu sắc (Color Customization)
        const Text(
          'Bảng màu tùy chỉnh',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Màu chính (Primary)
        _buildColorTile(
          context: context,
          title: 'Màu thương hiệu chính (Primary)',
          subtitle: 'Dùng cho điểm nhấn, nút bấm và viền thẻ',
          color: d.primaryColor,
          onTap: () async {
            final picked = await ColorPickerSheet.show(
              context: context,
              title: 'Màu chính (Primary)',
              initialColor: d.primaryColor,
            );
            if (picked != null) {
              controller.updateDesign(d.copyWith(primaryColor: picked));
            }
          },
        ),

        const SizedBox(height: 10),

        // Màu phụ (Secondary)
        _buildColorTile(
          context: context,
          title: 'Màu phụ (Secondary)',
          subtitle: 'Dùng cho dải chuyển màu và phụ đề',
          color: d.secondaryColor,
          onTap: () async {
            final picked = await ColorPickerSheet.show(
              context: context,
              title: 'Màu phụ (Secondary)',
              initialColor: d.secondaryColor,
            );
            if (picked != null) {
              controller.updateDesign(d.copyWith(secondaryColor: picked));
            }
          },
        ),

        const SizedBox(height: 10),

        // Màu nền thẻ (Background) - Kèm WCAG check với text color
        _buildColorTile(
          context: context,
          title: 'Màu nền thẻ (Background)',
          subtitle: 'Màu mặt lưng danh thiếp',
          color: d.backgroundColor,
          onTap: () async {
            final picked = await ColorPickerSheet.show(
              context: context,
              title: 'Màu nền (Background)',
              initialColor: d.backgroundColor,
              compareColor: d.textColor,
              isTextColor: false,
            );
            if (picked != null) {
              controller.updateDesign(d.copyWith(backgroundColor: picked));
            }
          },
        ),

        const SizedBox(height: 10),

        // Màu chữ (Text) - Kèm WCAG check với background color
        _buildColorTile(
          context: context,
          title: 'Màu văn bản (Text Color)',
          subtitle: 'Kiểm tra độ dễ đọc và tương phản WCAG',
          color: d.textColor,
          onTap: () async {
            final picked = await ColorPickerSheet.show(
              context: context,
              title: 'Màu chữ (Text Color)',
              initialColor: d.textColor,
              compareColor: d.backgroundColor,
              isTextColor: true,
            );
            if (picked != null) {
              controller.updateDesign(d.copyWith(textColor: picked));
            }
          },
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // 3. Phông chữ (Google Fonts)
        const Text(
          'Phông chữ (Typography)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          leading: const Icon(Icons.font_download_outlined, color: Color(0xFF1E88E5)),
          title: Text(
            d.fontFamily,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: const Text('Hỗ trợ đầy đủ tiếng Việt có dấu'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final selectedFont = await FontPickerSheet.show(
              context: context,
              currentFontFamily: d.fontFamily,
            );
            if (selectedFont != null) {
              controller.updateDesign(d.copyWith(fontFamily: selectedFont));
            }
          },
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // 4. Bo góc thẻ & Tùy chọn khác
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Độ bo góc thẻ (Corner Radius)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              '${d.cornerRadius.toInt()} px',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E88E5)),
            ),
          ],
        ),
        Slider(
          value: d.cornerRadius,
          min: 0,
          max: 32,
          divisions: 16,
          label: '${d.cornerRadius.toInt()} px',
          onChanged: (val) {
            controller.updateDesign(d.copyWith(cornerRadius: val));
          },
        ),

        const SizedBox(height: 12),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Hiển thị ảnh bìa (Banner)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Bật hoặc ẩn thanh ảnh bìa phía trên thẻ'),
          value: d.showBanner,
          onChanged: (val) {
            controller.updateDesign(d.copyWith(showBanner: val));
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildColorTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: Text(
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}
