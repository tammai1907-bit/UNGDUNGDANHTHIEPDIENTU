import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../services/contact_service.dart';
import '../../domain/entities/saved_contact.dart';
import '../providers/contact_providers.dart';

class ContactDetailScreen extends ConsumerStatefulWidget {
  final SavedContact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  ConsumerState<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen> {
  late TextEditingController _notesController;
  late List<String> _currentTags;
  bool _isEditingNotes = false;
  late SavedContact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    _notesController = TextEditingController(text: _contact.notes ?? '');
    _currentTags = List.from(_contact.tags);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _launch(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _saveNotesAndTags() async {
    final updated = _contact.copyWith(
      notes: _notesController.text.trim(),
      tags: _currentTags,
    );

    final controller = ref.read(contactControllerProvider.notifier);
    final result = await controller.updateContact(updated);

    if (mounted) {
      if (result.isSuccess) {
        setState(() {
          _contact = updated;
          _isEditingNotes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('Đã cập nhật ghi chú & nhãn phân loại thành công!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Cập nhật thất bại: ${result.errorOrNull}'),
          ),
        );
      }
    }
  }

  void _showAddTagDialog() {
    final available = ref.read(availableTagsProvider).where((t) => t != 'Tất cả' && !_currentTags.contains(t)).toList();
    final customTagController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Gán nhãn phân loại'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (available.isNotEmpty) ...[
                    const Text('Nhãn gợi ý sẵn có:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.map((tag) {
                        return ActionChip(
                          label: Text(tag),
                          avatar: const Icon(Icons.add, size: 16),
                          onPressed: () {
                            setState(() {
                              _currentTags.add(tag);
                            });
                            _saveNotesAndTags();
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                  ],
                  const Text('Hoặc tạo nhãn mới:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customTagController,
                    autofocus: available.isEmpty,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhãn (ví dụ: Khách hàng, Sự kiện, VIP...)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              FilledButton(
                onPressed: () {
                  final newTag = customTagController.text.trim();
                  if (newTag.isNotEmpty && !_currentTags.contains(newTag)) {
                    setState(() => _currentTags.add(newTag));
                    // Lưu vào custom tags chung
                    final allCustom = ref.read(userCustomTagsProvider);
                    if (!allCustom.contains(newTag)) {
                      ref.read(userCustomTagsProvider.notifier).state = [...allCustom, newTag];
                    }
                    _saveNotesAndTags();
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Thêm nhãn'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _syncToNativeContacts() async {
    final success = await ContactService.instance.saveCardToNativeContacts(
      fullName: _contact.fullName,
      phone: _contact.phone ?? '',
      email: _contact.email,
      company: _contact.company,
      jobTitle: _contact.jobTitle,
      website: _contact.website,
      address: _contact.address,
      note: _contact.notes,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Đã đồng bộ thông tin đối tác vào Danh bạ gốc điện thoại!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Không thể đồng bộ vào danh bạ thiết bị (Vui lòng cấp quyền truy cập danh bạ)'),
        ),
      );
    }
  }

  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        content: Text('Đã sao chép $fieldName: $text'),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa liên hệ'),
        content: Text('Bạn có chắc chắn muốn xóa liên hệ "${_contact.fullName}" khỏi Ví danh bạ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final controller = ref.read(contactControllerProvider.notifier);
      await controller.deleteContact(_contact.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa liên hệ khỏi Ví danh bạ')),
        );
      }
    }
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Khách hàng':
        return const Color(0xFF2563EB);
      case 'Đồng nghiệp':
        return const Color(0xFF16A34A);
      case 'Sự kiện':
        return const Color(0xFFD97706);
      case 'Đối tác':
        return const Color(0xFF0D9488);
      case 'VIP':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _contact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Đối Tác (CRM)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt_rounded),
            tooltip: 'Đồng bộ ra danh bạ máy',
            onPressed: _syncToNativeContacts,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Xóa đối tác',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card Avatar & Name
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      child: Text(
                        c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      c.fullName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (c.jobTitle != null && c.jobTitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        c.jobTitle!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (c.company != null && c.company!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        c.company!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (c.source != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  c.source!.contains('NFC') ? Icons.nfc : Icons.qr_code_2,
                                  size: 13,
                                  color: const Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  c.source!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu: ${c.savedAt.day}/${c.savedAt.month}/${c.savedAt.year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Các nút hành động gọi / SMS / Email nhanh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (c.phone != null && c.phone!.isNotEmpty) ...[
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                      icon: const Icon(Icons.phone),
                      tooltip: 'Gọi điện',
                      onPressed: () => _launch('tel:${c.phone}'),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      icon: const Icon(Icons.sms),
                      tooltip: 'Nhắn tin SMS',
                      onPressed: () => _launch('sms:${c.phone}'),
                    ),
                  ],
                  if (c.email != null && c.email!.isNotEmpty)
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                      icon: const Icon(Icons.email),
                      tooltip: 'Gửi Email',
                      onPressed: () => _launch('mailto:${c.email}'),
                    ),
                  if (c.website != null && c.website!.isNotEmpty)
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                      icon: const Icon(Icons.language),
                      tooltip: 'Trang web',
                      onPressed: () => _launch(c.website!),
                    ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.contact_phone_rounded),
                    tooltip: 'Đồng bộ danh bạ máy',
                    onPressed: _syncToNativeContacts,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Mục Thẻ phân loại (Tags: Khách hàng, Đồng nghiệp, Sự kiện...)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.label_outline, color: Color(0xFF2563EB), size: 20),
                            SizedBox(width: 8),
                            Text('Nhãn phân loại (CRM)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _showAddTagDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Gán nhãn'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_currentTags.isEmpty)
                      const Text(
                        'Chưa gán nhãn nào. Bấm "Gán nhãn" để phân loại đối tác (Khách hàng, Đồng nghiệp, Sự kiện...).',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentTags.map((tag) {
                          final color = _getTagColor(tag);
                          return Chip(
                            label: Text(tag, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                            backgroundColor: color.withValues(alpha: 0.1),
                            side: BorderSide(color: color.withValues(alpha: 0.3)),
                            deleteIcon: Icon(Icons.close, size: 16, color: color),
                            onDeleted: () {
                              setState(() => _currentTags.remove(tag));
                              _saveNotesAndTags();
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Mục Ghi chú riêng cho từng người (Contextual CRM Notes)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note, color: Color(0xFFD97706), size: 22),
                            SizedBox(width: 8),
                            Text('Ghi chú ngữ cảnh gặp gỡ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!_isEditingNotes)
                          TextButton.icon(
                            onPressed: () => setState(() => _isEditingNotes = true),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Chỉnh sửa'),
                          )
                        else
                          TextButton.icon(
                            onPressed: _saveNotesAndTags,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Lưu ghi chú'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isEditingNotes) ...[
                      // Gợi ý ghi chú nhanh
                      const Text('Gợi ý mẫu ghi chú:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          'Gặp tại sự kiện / hội thảo',
                          'Khách hàng tiềm năng: Cần gửi báo giá',
                          'Hẹn lịch trao đổi tuần tới',
                          'Đồng nghiệp chia sẻ chuyên môn',
                        ].map((template) {
                          return ActionChip(
                            label: Text(template, style: const TextStyle(fontSize: 11)),
                            onPressed: () {
                              final currentText = _notesController.text;
                              if (currentText.isEmpty) {
                                _notesController.text = template;
                              } else {
                                _notesController.text = '$currentText. $template';
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Nhập bối cảnh gặp gỡ, công việc cần follow-up...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ] else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _notesController.text.isNotEmpty
                              ? _notesController.text
                              : 'Chưa có ghi chú nào. Nhấn "Chỉnh sửa" để ghi nhớ bối cảnh gặp gỡ, triển lãm hoặc các việc cần làm.',
                          style: TextStyle(
                            fontStyle: _notesController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                            color: _notesController.text.isEmpty ? Colors.grey : null,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Danh sách thông tin chi tiết
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin liên lạc chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    if (c.phone != null && c.phone!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        title: 'Số điện thoại',
                        value: c.phone!,
                        onTap: () => _launch('tel:${c.phone}'),
                        onCopy: () => _copyToClipboard(c.phone!, 'Số điện thoại'),
                      ),
                    if (c.email != null && c.email!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: c.email!,
                        onTap: () => _launch('mailto:${c.email}'),
                        onCopy: () => _copyToClipboard(c.email!, 'Email'),
                      ),
                    if (c.website != null && c.website!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.language_outlined,
                        title: 'Website',
                        value: c.website!,
                        onTap: () => _launch(c.website!),
                        onCopy: () => _copyToClipboard(c.website!, 'Website'),
                      ),
                    if (c.company != null && c.company!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.business_outlined,
                        title: 'Công ty',
                        value: c.company!,
                        onCopy: () => _copyToClipboard(c.company!, 'Tên công ty'),
                      ),
                    if (c.savedLocation != null && c.savedLocation!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.place_outlined,
                        title: 'Địa điểm gặp gỡ',
                        value: c.savedLocation!,
                        onCopy: () => _copyToClipboard(c.savedLocation!, 'Địa điểm'),
                      ),
                    if (c.address != null && c.address!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.home_work_outlined,
                        title: 'Địa chỉ công tác',
                        value: c.address!,
                        onCopy: () => _copyToClipboard(c.address!, 'Địa chỉ'),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onTap != null ? const Color(0xFF2563EB) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
              tooltip: 'Sao chép',
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}
