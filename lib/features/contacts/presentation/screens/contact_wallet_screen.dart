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
  ConsumerState<ContactWalletScreen> createState() => _ContactWalletScreenState();
}

class _ContactWalletScreenState extends ConsumerState<ContactWalletScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _defaultFilterTags = [
    'Tất cả',
    'Khách hàng',
    'Đối tác',
    'Đồng nghiệp',
    'VIP',
    'Hội thảo',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final jobController = TextEditingController();
    final companyController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String selectedTag = 'Khách hàng';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    const Text('Thêm Liên Hệ Vào Ví', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Họ và tên *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: jobController,
                      decoration: const InputDecoration(labelText: 'Chức danh', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(labelText: 'Công ty', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
                    const Text('Phân loại nhóm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Khách hàng', 'Đối tác', 'Đồng nghiệp', 'VIP'].map((t) {
                        return ChoiceChip(
                          label: Text(t),
                          selected: selectedTag == t,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedTag = t);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          final newContact = SavedContact(
                            id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
                            ownerId: 'user_current',
                            fullName: name,
                            jobTitle: jobController.text.trim(),
                            company: companyController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            tags: [selectedTag],
                            savedAt: DateTime.now(),
                          );

                          final controller = ref.read(contactControllerProvider.notifier);
                          await controller.addContact(newContact);

                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('Lưu Liên Hệ'),
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

  @override
  Widget build(BuildContext context) {
    final filteredContactsAsync = ref.watch(filteredContactsProvider);
    final selectedTag = ref.watch(selectedTagFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví Danh Bạ Số'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Quét QR thêm liên hệ',
            onPressed: () => context.push('/scan-qr'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm liên hệ'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm họ tên, công ty, SĐT, ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(contactSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: (val) {
                ref.read(contactSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Thanh lọc Tag ngang
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _defaultFilterTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = _defaultFilterTags[index];
                final isSelected = selectedTag == tag;
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref.read(selectedTagFilterProvider.notifier).state = tag;
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách liên hệ
          Expanded(
            child: filteredContactsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (contacts) {
                if (contacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.contact_phone_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 14),
                        const Text('Không tìm thấy danh thiếp nào', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('Thử quét mã QR hoặc đổi từ khóa tìm kiếm', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/scan-qr'),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Quét mã QR ngay'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final c = contacts[index];

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
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
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar chữ cái
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                child: Text(
                                  c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (c.jobTitle != null && c.jobTitle!.isNotEmpty)
                                      Text(
                                        c.jobTitle!,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                                      ),
                                    if (c.company != null && c.company!.isNotEmpty)
                                      Text(
                                        c.company!,
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    if (c.tags.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: c.tags.take(2).map((t) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Nút gọi điện nhanh
                              if (c.phone != null && c.phone!.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.phone, color: Color(0xFF16A34A)),
                                  tooltip: 'Gọi điện',
                                  onPressed: () => _makeCall(c.phone!),
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
