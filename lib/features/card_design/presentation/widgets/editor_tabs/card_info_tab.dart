import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'package:digital_business_card/core/validators/card_validators.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/image_upload_field.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_editor_controller.dart';

/// Tab 1: Nhập thông tin cá nhân & hình ảnh của danh thiếp
class CardInfoTab extends ConsumerStatefulWidget {
  final BusinessCard? card;

  const CardInfoTab({super.key, this.card});

  @override
  ConsumerState<CardInfoTab> createState() => _CardInfoTabState();
}

class _CardInfoTabState extends ConsumerState<CardInfoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TextEditingController _cardNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final c = ref.read(cardEditorControllerProvider(widget.card)).card;
    _cardNameController = TextEditingController(text: c.cardName);
    _fullNameController = TextEditingController(text: c.fullName);
    _jobTitleController = TextEditingController(text: c.jobTitle);
    _companyController = TextEditingController(text: c.company);
    _bioController = TextEditingController(text: c.bio ?? '');
    _phoneController = TextEditingController(text: c.phone ?? '');
    _emailController = TextEditingController(text: c.email ?? '');
    _websiteController = TextEditingController(text: c.website ?? '');
    _addressController = TextEditingController(text: c.address ?? '');
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    ref.read(cardEditorControllerProvider(widget.card).notifier).updateBasicInfo(
          cardName: _cardNameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          company: _companyController.text.trim(),
          bio: _bioController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          website: _websiteController.text.trim(),
          address: _addressController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final editorState = ref.watch(cardEditorControllerProvider(widget.card));
    final card = editorState.card;
    final controller = ref.read(cardEditorControllerProvider(widget.card).notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Tên gợi nhớ danh thiếp
        TextFormField(
          controller: _cardNameController,
          decoration: InputDecoration(
            labelText: 'Tên danh thiếp * (Ví dụ: Thẻ Công việc, Thẻ Freelance)',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => CardValidators.validateRequired(v, fieldName: 'Tên danh thiếp'),
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 16),

        // Họ và tên
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Họ và tên *',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => CardValidators.validateRequired(v, fieldName: 'Họ và tên'),
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 16),

        // Chức vụ & Công ty
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _jobTitleController,
                decoration: InputDecoration(
                  labelText: 'Chức danh *',
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => CardValidators.validateRequired(v, fieldName: 'Chức danh'),
                onChanged: (_) => _onFieldChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: 'Công ty *',
                  prefixIcon: const Icon(Icons.business_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => CardValidators.validateRequired(v, fieldName: 'Công ty'),
                onChanged: (_) => _onFieldChanged(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Tiểu sử / Bio
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          maxLength: CardConstants.maxBioLength,
          decoration: InputDecoration(
            labelText: 'Giới thiệu ngắn (Bio)',
            alignLabelWithHint: true,
            hintText: 'Mô tả chuyên môn, lĩnh vực hoạt động...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description_outlined),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 16),

        // Số điện thoại & Email
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            hintText: '0987 654 321',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: CardValidators.validatePhoneVN,
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'email@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: CardValidators.validateEmail,
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 16),

        // Website & Địa chỉ
        TextFormField(
          controller: _websiteController,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            labelText: 'Website',
            hintText: 'https://techcorp.vn',
            prefixIcon: const Icon(Icons.language_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: CardValidators.validateUrl,
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Địa chỉ / Văn phòng',
            hintText: 'Quận 1, TP. Hồ Chí Minh',
            prefixIcon: const Icon(Icons.place_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (_) => _onFieldChanged(),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Hình ảnh (Avatar & Banner)
        const Text(
          'Hình ảnh danh thiếp',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ImageUploadField(
                label: 'Ảnh đại diện (1:1)',
                currentImageUrl: editorState.localAvatarPath ?? card.avatarUrl,
                cropType: ImageCropType.square,
                onImageSelected: (path) => controller.setAvatarLocal(path),
                onImageRemoved: () => controller.removeAvatar(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ImageUploadField(
                label: 'Ảnh bìa Banner (16:9)',
                currentImageUrl: editorState.localBannerPath ?? card.bannerUrl,
                cropType: ImageCropType.banner,
                onImageSelected: (path) => controller.setBannerLocal(path),
                onImageRemoved: () => controller.removeBanner(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
