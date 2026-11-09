import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.contact.notes ?? '');
    _currentTags = List.from(widget.contact.tags);
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
    final updated = widget.contact.copyWith(
      notes: _notesController.text.trim(),
      tags: _currentTags,
    );

    final controller = ref.read(contactControllerProvider.notifier);
    final result = await controller.updateContact(updated);

    if (mounted) {
      if (result.isSuccess) {
        setState(() => _isEditingNotes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('Đã cập nhật ghi chú & thẻ phân loại!'),
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
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm thẻ phân loại'),
        content: TextField(
          controller: tagController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên thẻ (ví dụ: Đối tác, VIP, Triển lãm)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              final newTag = tagController.text.trim();
              if (newTag.isNotEmpty && !_currentTags.contains(newTag)) {
                setState(() => _currentTags.add(newTag));
                _saveNotesAndTags();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa liên hệ'),
        content: Text('Bạn có chắc chắn muốn xóa liên hệ "${widget.contact.fullName}" khỏi Ví danh bạ?'),
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
      await controller.deleteContact(widget.contact.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa liên hệ khỏi Ví danh bạ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Liên Hệ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Xóa liên hệ',
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
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Các nút gọi / SMS / Email nhanh
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
                ],
              ),

              const SizedBox(height: 24),

              // Thẻ phân loại (Tags)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thẻ phân loại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _showAddTagDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm thẻ'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _currentTags.remove(tag));
                      _saveNotesAndTags();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Ghi chú ngữ cảnh gặp gỡ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ghi chú ngữ cảnh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      label: const Text('Lưu'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isEditingNotes)
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Gặp tại Hội nghị CNTT 2026, cần gửi báo giá tuần tới...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _notesController.text.isNotEmpty
                        ? _notesController.text
                        : 'Chưa có ghi chú nào. Nhấn "Chỉnh sửa" để ghi nhớ bối cảnh gặp gỡ.',
                    style: TextStyle(
                      fontStyle: _notesController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: _notesController.text.isEmpty ? Colors.grey : null,
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
