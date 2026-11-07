import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/business_card_model.dart';
import '../../config/app_constants.dart';
import '../../providers/card_provider.dart';
import '../../widgets/business_card_view.dart';

class CardBuilderScreen extends StatefulWidget {
  final BusinessCardModel? existingCard;

  const CardBuilderScreen({super.key, this.existingCard});

  @override
  State<CardBuilderScreen> createState() => _CardBuilderScreenState();
}

class _CardBuilderScreenState extends State<CardBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cardNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  late TextEditingController _linkedinController;
  late TextEditingController _facebookController;
  late TextEditingController _zaloController;
  late TextEditingController _githubController;
  late TextEditingController _skillsController;

  CardTemplateType _selectedTemplate = CardTemplateType.modern;
  String _selectedThemeColorId = 'navy_blue';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;

    _cardNameController = TextEditingController(text: card?.cardName ?? 'Công Việc Chính Thức');
    _fullNameController = TextEditingController(text: card?.fullName ?? '');
    _jobTitleController = TextEditingController(text: card?.jobTitle ?? '');
    _companyController = TextEditingController(text: card?.company ?? '');
    _phoneController = TextEditingController(text: card?.phone ?? '');
    _emailController = TextEditingController(text: card?.email ?? '');
    _websiteController = TextEditingController(text: card?.website ?? '');
    _addressController = TextEditingController(text: card?.address ?? '');
    _bioController = TextEditingController(text: card?.bio ?? '');

    _linkedinController = TextEditingController(text: card?.socialLinks['linkedin'] ?? '');
    _facebookController = TextEditingController(text: card?.socialLinks['facebook'] ?? '');
    _zaloController = TextEditingController(text: card?.socialLinks['zalo'] ?? '');
    _githubController = TextEditingController(text: card?.socialLinks['github'] ?? '');
    _skillsController = TextEditingController(text: card?.skills.join(', ') ?? '');

    if (card != null) {
      _selectedTemplate = card.template;
      _selectedThemeColorId = card.themeColorId;
      _isDefault = card.isDefault;
    }
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    _zaloController.dispose();
    _githubController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  BusinessCardModel _buildCurrentPreviewCard() {
    final Map<String, String> socials = {};
    if (_linkedinController.text.isNotEmpty) socials['linkedin'] = _linkedinController.text;
    if (_facebookController.text.isNotEmpty) socials['facebook'] = _facebookController.text;
    if (_zaloController.text.isNotEmpty) socials['zalo'] = _zaloController.text;
    if (_githubController.text.isNotEmpty) socials['github'] = _githubController.text;

    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return BusinessCardModel(
      id: widget.existingCard?.id ?? 'preview',
      userId: widget.existingCard?.userId ?? 'user_current',
      cardName: _cardNameController.text.isEmpty ? 'Tên danh thiếp' : _cardNameController.text,
      fullName: _fullNameController.text.isEmpty ? 'Họ và Tên' : _fullNameController.text,
      jobTitle: _jobTitleController.text.isEmpty ? 'Chức danh nghề nghiệp' : _jobTitleController.text,
      company: _companyController.text.isEmpty ? 'Công ty / Đơn vị' : _companyController.text,
      phone: _phoneController.text.isEmpty ? '0901234567' : _phoneController.text,
      email: _emailController.text.isEmpty ? 'email@company.com' : _emailController.text,
      website: _websiteController.text,
      address: _addressController.text,
      bio: _bioController.text,
      socialLinks: socials,
      template: _selectedTemplate,
      themeColorId: _selectedThemeColorId,
      skills: skillsList,
      isDefault: _isDefault,
      createdAt: widget.existingCard?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final cardToSave = _buildCurrentPreviewCard().copyWith(
      id: widget.existingCard?.id ?? const Uuid().v4(),
    );

    if (widget.existingCard == null) {
      await cardProvider.addCard(cardToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo danh thiếp số mới thành công!')),
        );
      }
    } else {
      await cardProvider.updateCard(cardToSave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật danh thiếp thành công!')),
        );
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCard == null ? 'Thiết Kế Danh Thiếp' : 'Chỉnh Sửa Danh Thiếp'),
        actions: [
          TextButton.icon(
            onPressed: _saveCard,
            icon: const Icon(Icons.check, color: Color(0xFF2563EB)),
            label: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Preview Card
              const Text(
                'Xem trước trực tiếp (Live Preview):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              BusinessCardView(
                card: _buildCurrentPreviewCard(),
                isInteractive: false,
              ),
              const SizedBox(height: 24),

              // Chọn Mẫu Giao Diện (Templates)
              const Text(
                '1. Chọn Mẫu Thiết Kế (Template)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: CardTemplateType.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final type = CardTemplateType.values[index];
                    final isSelected = _selectedTemplate == type;
                    return InkWell(
                      onTap: () => setState(() => _selectedTemplate = type),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB).withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(type.icon, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                            const SizedBox(height: 6),
                            Text(
                              type.displayName.split(' ')[0],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Chọn Bảng Màu (Color Palette)
              const Text(
                '2. Bảng Màu Chủ Đạo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.themeColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final theme = AppConstants.themeColors[index];
                    final isSelected = _selectedThemeColorId == theme['id'];
                    final primaryColor = theme['primary'] as Color;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedThemeColorId = theme['id']),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black87 : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Nhập Thông Tin Cơ Bản
              const Text(
                '3. Thông Tin Hồ Sơ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cardNameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Tên định danh hồ sơ (*)',
                  hintText: 'VD: Công việc chính thức, Freelance, Dự án AI...',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên hồ sơ' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _fullNameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Họ và tên (*)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _jobTitleController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Chức danh nghề nghiệp (*)',
                  hintText: 'VD: Senior Mobile Engineer / Giám đốc kinh doanh',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập chức danh' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _companyController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Công ty / Đơn vị tổ chức (*)',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập công ty' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại (*)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập SĐT' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Email liên hệ (*)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập Email' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _websiteController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Website / Portfolio link',
                  prefixIcon: Icon(Icons.language_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ nơi làm việc',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _bioController,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Giới thiệu ngắn (Bio / Slogan)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Liên Kết Mạng Xã Hội
              const Text(
                '4. Mạng Xã Hội & Kỹ Năng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _linkedinController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'LinkedIn URL',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _githubController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'GitHub URL',
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _facebookController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Facebook / Zalo URL',
                  prefixIcon: Icon(Icons.share_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _skillsController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Kỹ năng (cách nhau bởi dấu phẩy)',
                  hintText: 'VD: Flutter, AI, Project Management, Agile',
                  prefixIcon: Icon(Icons.stars_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Switch Đặt làm thẻ mặc định
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Đặt làm danh thiếp mặc định', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Danh thiếp này sẽ được ưu tiên hiển thị và chia sẻ nhanh qua QR/NFC'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 30),

              // Nút Submit Lưu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveCard,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Lưu Danh Thiếp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
