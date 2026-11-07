import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/wallet_provider.dart';
import '../../models/saved_contact_model.dart';
import '../../services/contact_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _saveToNativeContacts(BuildContext context, SavedContactModel contact) async {
    final success = await ContactService.instance.saveCardToNativeContacts(
      fullName: contact.fullName,
      phone: contact.phone,
      email: contact.email,
      company: contact.company,
      jobTitle: contact.jobTitle,
      website: contact.website,
      address: contact.address,
      note: contact.notes,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Đã lưu ${contact.fullName} vào Danh bạ gốc điện thoại!'),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể truy cập danh bạ thiết bị (Vui lòng cấp quyền)'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showEditNotesDialog(BuildContext context, SavedContactModel contact) {
    final noteController = TextEditingController(text: contact.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ghi Chú Về ${contact.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi chú ngữ cảnh gặp gỡ hoặc lời nhắc công việc:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'VD: Hẹn gửi báo giá vào thứ Tư tuần sau; quen tại hội nghị AI...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Provider.of<WalletProvider>(context, listen: false).updateContextNotes(
                contact.id,
                noteController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật ghi chú ngữ cảnh!')),
              );
            },
            child: const Text('Lưu Ghi Chú'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final contacts = walletProvider.filteredContacts;

    const availableTags = ['Tất cả', 'Khách hàng', 'Đối tác', 'Đồng nghiệp', 'Bạn bè', 'VIP'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví Danh Thiếp (Contact Wallet)'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => walletProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, công ty, SĐT, địa điểm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: walletProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => walletProvider.setSearchQuery(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter by Tag chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = availableTags[index];
                final isSelected = walletProvider.selectedTag == tag;

                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (_) => walletProvider.filterByTag(tag),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Contacts List
          Expanded(
            child: walletProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_shared_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text(
                              'Chưa có danh thiếp nào trong ví',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Quét mã QR hoặc chạm NFC để thu thập danh thiếp ngay!',
                              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: contacts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = contacts[index];
                          final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(item.metAt);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Avatar, Info, Favorite
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                      child: Text(
                                        item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : 'C',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.fullName,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          if (item.jobTitle.isNotEmpty)
                                            Text(
                                              item.jobTitle,
                                              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                            ),
                                          if (item.company.isNotEmpty)
                                            Text(
                                              item.company,
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        item.isFavorite ? Icons.star : Icons.star_border,
                                        color: item.isFavorite ? Colors.amber : const Color(0xFF94A3B8),
                                      ),
                                      onPressed: () => walletProvider.toggleFavorite(item),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // GPS Location & Meeting Time
                                if (item.locationName != null || item.latitude != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Color(0xFFE11D48)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${item.locationName ?? "Tọa độ GPS"} • $formattedDate',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // Contextual Notes
                                if (item.notes.isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF9C3), // Vàng nhạt kiểu sticky note
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFDE047)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.edit_note, size: 16, color: Color(0xFF854D0E)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item.notes,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF713F12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Action Buttons: Native Contact Save, Call, Email, Notes
                                Row(
                                  children: [
                                    // Nút Lưu vào Danh bạ gốc (Core Feature ăn điểm)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          side: const BorderSide(color: Color(0xFF16A34A)),
                                          foregroundColor: const Color(0xFF16A34A),
                                        ),
                                        onPressed: () => _saveToNativeContacts(context, item),
                                        icon: const Icon(Icons.person_add_alt_1, size: 16),
                                        label: const Text('Lưu Danh Bạ Máy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Gọi điện
                                    if (item.phone.isNotEmpty)
                                      IconButton.filledTonal(
                                        icon: const Icon(Icons.phone, size: 18),
                                        onPressed: () => _callPhone(item.phone),
                                      ),

                                    // Email
                                    if (item.email.isNotEmpty)
                                      IconButton.filledTonal(
                                        icon: const Icon(Icons.email, size: 18),
                                        onPressed: () => _sendEmail(item.email),
                                      ),

                                    // Sửa ghi chú ngữ cảnh
                                    IconButton.outlined(
                                      icon: const Icon(Icons.note_alt_outlined, size: 18),
                                      onPressed: () => _showEditNotesDialog(context, item),
                                    ),

                                    // Xóa liên hệ
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                      onPressed: () => walletProvider.deleteContact(item.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
