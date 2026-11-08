import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'package:digital_business_card/core/validators/card_validators.dart';
import 'package:digital_business_card/features/card_design/domain/entities/social_link.dart';

/// Bottom sheet thêm hoặc sửa liên kết mạng xã hội
class SocialLinkEditorSheet extends StatefulWidget {
  final SocialLink? initialLink;
  final ValueChanged<SocialLink> onSave;

  const SocialLinkEditorSheet({
    super.key,
    this.initialLink,
    required this.onSave,
  });

  static Future<SocialLink?> show({
    required BuildContext context,
    SocialLink? initialLink,
  }) {
    return showModalBottomSheet<SocialLink>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, __) => SocialLinkEditorSheet(
            initialLink: initialLink,
            onSave: (link) => Navigator.pop(ctx, link),
          ),
        ),
      ),
    );
  }

  @override
  State<SocialLinkEditorSheet> createState() => _SocialLinkEditorSheetState();
}

class _SocialLinkEditorSheetState extends State<SocialLinkEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late SocialLinkType _selectedType;
  late TextEditingController _valueController;
  late TextEditingController _labelController;
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    final link = widget.initialLink;
    _selectedType = link?.type ?? SocialLinkType.phone;
    _valueController = TextEditingController(text: link?.value ?? '');
    _labelController = TextEditingController(text: link?.label ?? '');
    _isVisible = link?.isVisible ?? true;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onTypeChanged(SocialLinkType newType) {
    setState(() {
      _selectedType = newType;
    });
  }

  Future<void> _testLink() async {
    final rawVal = _valueController.text.trim();
    if (rawVal.isEmpty) return;

    final normalized = CardValidators.normalizeSocialUrl(_selectedType, rawVal);
    final uri = Uri.tryParse(normalized);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở liên kết: $normalized')),
          );
        }
      }
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final rawVal = _valueController.text.trim();
    final normalized = CardValidators.normalizeSocialUrl(_selectedType, rawVal);

    final link = SocialLink(
      id: widget.initialLink?.id ?? const Uuid().v4(),
      type: _selectedType,
      value: normalized,
      label: _labelController.text.trim().isNotEmpty
          ? _labelController.text.trim()
          : null,
      order: widget.initialLink?.order ?? 0,
      isVisible: _isVisible,
    );

    widget.onSave(link);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialLink != null;
    final meta = CardConstants.getSocialMeta(_selectedType.name);

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

        // Tiêu đề & Nút lưu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Sửa Liên Kết' : 'Thêm Liên Kết Mới',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FilledButton(
                onPressed: _handleSave,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),

        const Divider(height: 16),

        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Chọn loại liên kết (Chips)
                const Text(
                  'Chọn loại liên kết',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SocialLinkType.values.map((type) {
                    final itemMeta = CardConstants.getSocialMeta(type.name);
                    final isSelected = type == _selectedType;

                    return ChoiceChip(
                      selected: isSelected,
                      avatar: Icon(
                        itemMeta.icon,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      label: Text(itemMeta.name),
                      onSelected: (val) {
                        if (val) _onTypeChanged(type);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Giá trị liên kết (SĐT, Email, URL, Username)
                TextFormField(
                  controller: _valueController,
                  keyboardType: _selectedType == SocialLinkType.phone ||
                          _selectedType == SocialLinkType.sms ||
                          _selectedType == SocialLinkType.zalo
                      ? TextInputType.phone
                      : (_selectedType == SocialLinkType.email
                          ? TextInputType.emailAddress
                          : TextInputType.url),
                  decoration: InputDecoration(
                    labelText: meta.name,
                    hintText: meta.placeholder,
                    prefixIcon: Icon(meta.icon),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      tooltip: 'Thử mở liên kết',
                      onPressed: _testLink,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập ${meta.name.toLowerCase()}';
                    }
                    if (_selectedType == SocialLinkType.email) {
                      return CardValidators.validateEmail(val);
                    }
                    if (_selectedType == SocialLinkType.phone ||
                        _selectedType == SocialLinkType.sms) {
                      return CardValidators.validatePhoneVN(val);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Nhãn hiển thị tùy chọn (Label)
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'Nhãn tùy chỉnh (Không bắt buộc)',
                    hintText: 'VD: Hotline công ty, Kênh YouTube cá nhân...',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),

                // Công tắc hiển thị
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hiển thị trên danh thiếp'),
                  subtitle: const Text('Bật để liên kết này xuất hiện trong thẻ'),
                  value: _isVisible,
                  onChanged: (val) => setState(() => _isVisible = val),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
