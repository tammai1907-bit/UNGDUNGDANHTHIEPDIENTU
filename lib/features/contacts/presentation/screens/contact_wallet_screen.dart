import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/saved_contact.dart';
import '../providers/contact_providers.dart';
import 'contact_detail_screen.dart';

class ContactWalletScreen extends ConsumerStatefulWidget {
  const ContactWalletScreen({super.key});

  @override
  ConsumerState<ContactWalletScreen> createState() =>
      _ContactWalletScreenState();
}

class _ContactWalletScreenState extends ConsumerState<ContactWalletScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateCustomTagDialog() {
    final tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.label_outline, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Tạo nhãn phân loại mới'),
          ],
        ),
        content: TextField(
          controller: tagCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText:
                'Tên nhãn mới (ví dụ: Khách hàng, Đồng nghiệp, Sự kiện...)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final newTag = tagCtrl.text.trim();
              if (newTag.isNotEmpty) {
                final current = ref.read(userCustomTagsProvider);
                if (!current.contains(newTag)) {
                  ref.read(userCustomTagsProvider.notifier).state = [
                    ...current,
                    newTag,
                  ];
                  ref.read(selectedTagFilterProvider.notifier).state = newTag;
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tạo nhãn'),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final jobController = TextEditingController();
    final companyController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final websiteController = TextEditingController();
    final notesController = TextEditingController();
    final locationController = TextEditingController();
    final selectedTags = <String>{'Khách hàng'};
    String selectedSource = 'Thủ công';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableTags = ref
                .watch(availableTagsProvider)
                .where((t) => t != 'Tất cả')
                .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thêm Đối Tác Vào Ví (CRM)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên đối tác *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: jobController,
                            decoration: const InputDecoration(
                              labelText: 'Chức danh',
                              prefixIcon: Icon(Icons.work_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: companyController,
                            decoration: const InputDecoration(
                              labelText: 'Công ty',
                              prefixIcon: Icon(Icons.business_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website / Portfolio',
                        prefixIcon: Icon(Icons.language_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Địa điểm gặp gỡ (sự kiện, hội nghị)',
                        prefixIcon: Icon(Icons.place_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Gán nhãn phân loại:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ...availableTags.map((t) {
                          final isSelected = selectedTags.contains(t);
                          return FilterChip(
                            label: Text(t),
                            selected: isSelected,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedTags.add(t);
                                } else {
                                  selectedTags.remove(t);
                                }
                              });
                            },
                          );
                        }),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text('Thêm nhãn mới'),
                          onPressed: () {
                            _showCreateCustomTagDialog();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Nguồn nhận danh thiếp:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Quét mã QR',
                          label: Text('Quét QR'),
                          icon: Icon(Icons.qr_code),
                        ),
                        ButtonSegment(
                          value: 'Chạm thẻ NFC',
                          label: Text('NFC'),
                          icon: Icon(Icons.nfc),
                        ),
                        ButtonSegment(
                          value: 'Thủ công',
                          label: Text('Thủ công'),
                          icon: Icon(Icons.edit),
                        ),
                      ],
                      selected: {selectedSource},
                      onSelectionChanged: (val) {
                        setModalState(() => selectedSource = val.first);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú ngữ cảnh gặp gỡ',
                        hintText: 'Ví dụ: Khách hàng tiềm năng, hẹn gặp lại tuần sau...',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'Lưu Vào Sổ Danh Bạ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng nhập họ và tên đối tác',
                                ),
                              ),
                            );
                            return;
                          }

                          final newContact = SavedContact(
                            id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
                            ownerId: 'user_current',
                            fullName: name,
                            jobTitle: jobController.text.trim().isNotEmpty
                                ? jobController.text.trim()
                                : null,
                            company: companyController.text.trim().isNotEmpty
                                ? companyController.text.trim()
                                : null,
                            phone: phoneController.text.trim().isNotEmpty
                                ? phoneController.text.trim()
                                : null,
                            email: emailController.text.trim().isNotEmpty
                                ? emailController.text.trim()
                                : null,
                            website: websiteController.text.trim().isNotEmpty
                                ? websiteController.text.trim()
                                : null,
                            savedLocation:
                                locationController.text.trim().isNotEmpty
                                ? locationController.text.trim()
                                : null,
                            tags: selectedTags.isNotEmpty
                                ? selectedTags.toList()
                                : ['Khách hàng'],
                            notes: notesController.text.trim().isNotEmpty
                                ? notesController.text.trim()
                                : null,
                            source: selectedSource,
                            savedAt: DateTime.now(),
                          );

                          final controller = ref.read(
                            contactControllerProvider.notifier,
                          );
                          final result = await controller.addContact(
                            newContact,
                          );
                          if (!result.isSuccess) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Không thể lưu liên hệ: ${result.errorOrNull}',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF16A34A),
                                content: Text(
                                  'Đã thêm "${newContact.fullName}" vào Ví danh bạ!',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSms(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Khách hàng':
        return const Color(0xFF2563EB); // Blue
      case 'Đồng nghiệp':
        return const Color(0xFF16A34A); // Green
      case 'Sự kiện':
        return const Color(0xFFD97706); // Amber / Orange
      case 'Đối tác':
        return const Color(0xFF0D9488); // Teal
      case 'VIP':
        return const Color(0xFF9333EA); // Purple
      default:
        return const Color(0xFF4F46E5); // Indigo
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContactsAsync = ref.watch(filteredContactsProvider);
    final allContactsAsync = ref.watch(contactsStreamProvider);
    final selectedTag = ref.watch(selectedTagFilterProvider);
    final availableTags = ref.watch(availableTagsProvider);
    final searchQuery = ref.watch(contactSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví Danh Bạ Số (CRM)'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Quét QR nhận danh thiếp',
            onPressed: () => context.push('/scan-qr'),
          ),
          IconButton(
            icon: const Icon(Icons.label_outlined),
            tooltip: 'Tạo nhãn mới',
            onPressed: _showCreateCustomTagDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          'Thêm liên hệ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm nhanh thông minh (Họ tên, Công ty, SĐT, Ghi chú)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 4,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm nhanh họ tên, công ty, SĐT, ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(contactSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (val) {
                ref.read(contactSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Thanh lọc Tag ngang có huy hiệu đếm số lượng
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: availableTags.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == availableTags.length) {
                  return ActionChip(
                    avatar: const Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    label: const Text(
                      'Tạo nhãn',
                      style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                    ),
                    onPressed: _showCreateCustomTagDialog,
                  );
                }

                final tag = availableTags[index];
                final isSelected = selectedTag == tag;

                // Tính số lượng liên hệ theo nhãn
                final count = allContactsAsync.maybeWhen(
                  data: (contacts) {
                    if (tag == 'Tất cả') return contacts.length;
                    return contacts.where((c) => c.tags.contains(tag)).length;
                  },
                  orElse: () => 0,
                );

                return ChoiceChip(
                  label: Text('$tag ($count)'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB)
                      .withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? const Color(0xFF2563EB) : null,
                  ),
                  onSelected: (val) {
                    if (val) {
                      ref.read(selectedTagFilterProvider.notifier).state = tag;
                    }
                  },
                );
              },
            ),
          ),

          // Dòng hiển thị kết quả tìm kiếm
          if (searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Kết quả tìm kiếm cho "$searchQuery":',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Danh sách liên hệ CRM
          Expanded(
            child: filteredContactsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (contacts) {
                if (contacts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.contact_mail_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có đối tác trong nhóm này',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Quét mã QR từ module Thành viên 3 hoặc nhấn "Thêm liên hệ" để bắt đầu quản lý mạng lưới quan hệ.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => context.push('/scan-qr'),
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const Text('Quét QR nhận danh thiếp'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 90,
                  ),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = contacts[index];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.18),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContactDetailScreen(contact: c),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar chữ cái với gradient
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.12),
                                    child: Text(
                                      c.fullName.isNotEmpty
                                          ? c.fullName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Tên, Chức danh, Công ty
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                c.fullName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (c.source != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      c.source!.contains('NFC')
                                                          ? Icons.nfc
                                                          : Icons.qr_code_2,
                                                      size: 11,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      c.source!,
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (c.jobTitle != null &&
                                            c.jobTitle!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            c.jobTitle!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (c.company != null &&
                                            c.company!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.business_outlined,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  c.company!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Nhãn phân loại Tags
                              if (c.tags.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: c.tags.map((t) {
                                    final color = _getTagColor(t);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        t,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],

                              // Ghi chú riêng cho từng người (Context CRM Note snippet)
                              if (c.notes != null && c.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.edit_note,
                                        size: 16,
                                        color: Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          c.notes!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Địa điểm & Ngày lưu & Các nút liên hệ nhanh
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (c.savedLocation != null &&
                                            c.savedLocation!.isNotEmpty) ...[
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 2),
                                          Flexible(
                                            child: Text(
                                              c.savedLocation!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          '${c.savedAt.day}/${c.savedAt.month}/${c.savedAt.year}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Nút gọi & SMS nhanh
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (c.phone != null &&
                                          c.phone!.isNotEmpty) ...[
                                        IconButton(
                                          icon: const Icon(
                                            Icons.sms_outlined,
                                            color: Color(0xFF2563EB),
                                            size: 20,
                                          ),
                                          tooltip: 'Nhắn tin SMS',
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _sendSms(c.phone!),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.phone_outlined,
                                            color: Color(0xFF16A34A),
                                            size: 20,
                                          ),
                                          tooltip: 'Gọi điện',
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _makeCall(c.phone!),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
