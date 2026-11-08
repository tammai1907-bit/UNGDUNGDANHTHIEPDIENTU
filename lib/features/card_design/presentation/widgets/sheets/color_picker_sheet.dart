import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'package:digital_business_card/core/utils/wcag_contrast.dart';

/// Bottom sheet chọn màu sắc hỗ trợ bảng màu gợi ý, mã Hex và kiểm tra tương phản WCAG
class ColorPickerSheet extends StatefulWidget {
  final String title;
  final Color initialColor;
  final Color? compareColor; // Màu đối ứng (ví dụ: màu chữ nếu đang chọn nền, hoặc màu nền nếu đang chọn chữ)
  final bool isTextColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerSheet({
    super.key,
    required this.title,
    required this.initialColor,
    this.compareColor,
    this.isTextColor = false,
    required this.onColorChanged,
  });

  static Future<Color?> show({
    required BuildContext context,
    required String title,
    required Color initialColor,
    Color? compareColor,
    bool isTextColor = false,
  }) {
    return showModalBottomSheet<Color>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ColorPickerSheet(
          title: title,
          initialColor: initialColor,
          compareColor: compareColor,
          isTextColor: isTextColor,
          onColorChanged: (_) {},
        ),
      ),
    );
  }

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late Color _currentColor;
  late TextEditingController _hexController;

  static String colorToHex(Color c) =>
      c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _hexController = TextEditingController(
      text: colorToHex(_currentColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _onColorUpdate(Color newColor) {
    setState(() {
      _currentColor = newColor;
      _hexController.text = colorToHex(newColor);
    });
    widget.onColorChanged(newColor);
  }

  @override
  Widget build(BuildContext context) {
    // Phân tích WCAG nếu có màu đối chiếu
    WcagEvaluation? wcag;
    if (widget.compareColor != null) {
      final textColor = widget.isTextColor ? _currentColor : widget.compareColor!;
      final bgColor = widget.isTextColor ? widget.compareColor! : _currentColor;
      wcag = WcagContrast.evaluate(textColor: textColor, backgroundColor: bgColor);
    }

    return Column(
      children: [
        // Thanh kéo (drag handle)
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

        // Tiêu đề & nút chọn
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, _currentColor),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ),

        const Divider(height: 20),

        // Nội dung cuộn
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              // Cảnh báo WCAG nếu tương phản kém
              if (wcag != null) _buildWcagBanner(wcag),

              // Xem trước màu đang chọn & Ô nhập mã HEX
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: [
                          BoxShadow(
                            color: _currentColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Mã HEX: #',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _hexController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 8,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'RRGGBB',
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        onChanged: (val) {
                          if (val.length == 6 || val.length == 8) {
                            final parsed = CardConstants.parseColor('#$val');
                            _onColorUpdate(parsed);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Bảng màu gợi ý',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Swatch gợi ý nhanh
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: CardConstants.suggestedPalette.map((item) {
                  final color = CardConstants.parseColor(item.hex);
                  final isSelected = _currentColor.toARGB32() == color.toARGB32();

                  return InkWell(
                    onTap: () => _onColorUpdate(color),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.black12,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Text(
                'Bảng chọn chi tiết',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Bảng chọn màu linh hoạt flex_color_picker
              ColorPicker(
                color: _currentColor,
                onColorChanged: _onColorUpdate,
                width: 38,
                height: 38,
                borderRadius: 8,
                spacing: 6,
                runSpacing: 6,
                heading: const SizedBox.shrink(),
                subheading: const SizedBox.shrink(),
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: true,
                  ColorPickerType.bw: true,
                  ColorPickerType.custom: false,
                  ColorPickerType.wheel: true,
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWcagBanner(WcagEvaluation wcag) {
    final isWarning = !wcag.passesNormalText;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isWarning ? Colors.amber.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? Colors.amber.shade400 : Colors.green.shade400,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: isWarning ? Colors.orange.shade800 : Colors.green.shade700,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWarning ? 'Cảnh báo tương phản thấp' : 'Độ tương phản đạt chuẩn WCAG AA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isWarning ? Colors.orange.shade900 : Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tỉ lệ tương phản: ${wcag.ratio.toStringAsFixed(2)}:1 ${wcag.warningMessage != null ? "(${wcag.warningMessage})" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isWarning ? Colors.brown.shade800 : Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
