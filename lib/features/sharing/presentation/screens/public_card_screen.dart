import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/domain/entities/social_link.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/card_preview.dart';
import 'package:digital_business_card/features/card_design/data/datasources/card_seed_data.dart';
import 'package:digital_business_card/features/sharing/utils/vcard_generator.dart';
import 'package:digital_business_card/features/contacts/domain/entities/saved_contact.dart';
import 'package:digital_business_card/features/contacts/presentation/providers/contact_providers.dart';
import 'package:digital_business_card/features/contacts/presentation/screens/contact_detail_screen.dart';
import 'package:digital_business_card/features/analytics/presentation/providers/analytics_providers.dart';

class PublicCardScreen extends ConsumerStatefulWidget {
  final String ownerId;
  final String cardId;
  final String source; // 'qr', 'nfc', 'direct'

  const PublicCardScreen({
    super.key,
    required this.ownerId,
    required this.cardId,
    this.source = 'direct',
  });

  @override
  ConsumerState<PublicCardScreen> createState() => _PublicCardScreenState();
}

class _PublicCardScreenState extends ConsumerState<PublicCardScreen> {
  bool _isLoading = true;
  BusinessCard? _card;
  String? _errorMessage;
  bool _hasLoggedView = false;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(cardRepositoryProvider);
      final res = await repository.getCardById(
        userId: widget.ownerId,
        cardId: widget.cardId,
      );
      final fetched = res.dataOrNull;

      if (fetched != null) {
        setState(() {
          _card = fetched;
          _isLoading = false;
        });
        _recordCardViewEvents(fetched.id);
        return;
      }

      // Fallback tìm trong danh sách mẫu nếu đang chạy InMemory
      final initialCards = CardSeedData.getInitialCards(widget.ownerId);
      final fallback = initialCards.cast<BusinessCard?>().firstWhere(
        (c) => c?.id == widget.cardId,
        orElse: () => initialCards.isNotEmpty ? initialCards.first : null,
      );

      setState(() {
        _card = fallback;
        _isLoading = false;
        if (fallback == null) {
          _errorMessage = 'Không tìm thấy thông tin danh thiếp này';
        }
      });

      if (fallback != null) {
        _recordCardViewEvents(fallback.id);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải danh thiếp: $e';
      });
    }
  }

  Future<void> _recordCardViewEvents(String cardId) async {
    if (_hasLoggedView) return;
    _hasLoggedView = true;

    final analyticsRepo = ref.read(analyticsRepositoryProvider);
    final eventType = switch (widget.source) {
      'qr' => 'qr_scan',
      'nfc' => 'nfc_tap',
      _ => 'view',
    };
    try {
      await analyticsRepo.recordEvent(cardId: cardId, eventType: eventType);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể ghi nhận lượt tương tác: $e')),
        );
      }
    }
  }

  Future<void> _launchUrlString(String urlStr, String linkType) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (_card != null) {
          await ref
              .read(analyticsRepositoryProvider)
              .recordEvent(
                cardId: _card!.id,
                eventType: 'link_click',
                linkType: linkType,
              );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở liên kết: $urlStr')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở liên kết hoặc ghi nhận lượt nhấn: $e'),
          ),
        );
      }
    }
  }

  /// Mở hộp thoại lưu đối tác vào Ví Danh Bạ Ứng Dụng (Module Thành viên 4)
  void _showSaveToWalletBottomSheet() {
    if (_card == null) return;
    final card = _card!;

    final defaultSourceText = widget.source == 'qr'
        ? 'Quét mã QR'
        : (widget.source == 'nfc' ? 'Chạm thẻ NFC' : 'Liên kết chia sẻ');

    final notesCtrl = TextEditingController(
      text: widget.source == 'qr'
          ? 'Quét mã QR danh thiếp đối tác.'
          : (widget.source == 'nfc' ? 'Nhận danh thiếp qua chạm thẻ NFC.' : ''),
    );
    final locationCtrl = TextEditingController();
    final selectedTags = <String>{'Khách hàng'};

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
                        const Row(
                          children: [
                            Icon(
                              Icons.bookmark_add_rounded,
                              color: Color(0xFF2563EB),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Lưu Vào Ví Danh Bạ (CRM)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Tóm tắt thông tin đối tác
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(
                              card.fullName.isNotEmpty
                                  ? card.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (card.jobTitle.isNotEmpty)
                                  Text(
                                    card.jobTitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                if (card.company.isNotEmpty)
                                  Text(
                                    card.company,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Gán nhãn phân loại đối tác:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: availableTags.map((t) {
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
                      }).toList(),
                    ),

                    const SizedBox(height: 14),
                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Địa điểm gặp gỡ (Sự kiện / Hội thảo)',
                        hintText: 'Ví dụ: Hội chợ Tech Expo 2026, Q.1',
                        prefixIcon: Icon(Icons.place_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú riêng về đối tác',
                        hintText: 'Bối cảnh gặp gỡ, công việc cần trao đổi...',
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
                          'Xác Nhận Lưu Vào Ví',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final savedContact = SavedContact.fromBusinessCard(
                            card,
                            tags: selectedTags.isNotEmpty
                                ? selectedTags.toList()
                                : ['Khách hàng'],
                            notes: notesCtrl.text.trim().isNotEmpty
                                ? notesCtrl.text.trim()
                                : null,
                            savedLocation: locationCtrl.text.trim().isNotEmpty
                                ? locationCtrl.text.trim()
                                : null,
                            source: defaultSourceText,
                          );

                          final controller = ref.read(
                            contactControllerProvider.notifier,
                          );
                          final result = await controller.addContact(
                            savedContact,
                          );
                          if (!result.isSuccess) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Không thể lưu danh thiếp: ${result.errorOrNull}',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          // Ghi nhận sự kiện Lưu danh bạ vào Analytics
                          try {
                            await ref
                                .read(analyticsRepositoryProvider)
                                .recordEvent(
                                  cardId: card.id,
                                  eventType: 'save',
                                );
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã lưu liên hệ nhưng không thể cập nhật thống kê: $e',
                                  ),
                                ),
                              );
                            }
                          }

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF16A34A),
                                content: Text(
                                  'Đã lưu danh thiếp của "${card.fullName}" vào Ví danh bạ!',
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

  /// Đồng bộ vào danh bạ gốc của điện thoại (Contacts Framework)
  Future<void> _handleSaveToNativeContacts() async {
    if (_card == null) return;
    final success = await VCardGenerator.saveToDeviceContacts(_card!);
    if (!mounted) return;

    if (success) {
      // Ghi nhận sự kiện lưu danh bạ
      ref
          .read(analyticsRepositoryProvider)
          .recordEvent(cardId: _card!.id, eventType: 'save');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A34A),
          content: Text('Đã lưu thông tin vào danh bạ điện thoại!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text(
            'Không thể lưu vào danh bạ (Vui lòng cấp quyền truy cập danh bạ)',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadySavedInWallet =
        _card != null && ref.watch(isCardSavedInWalletProvider(_card!.id));
    final contactsListAsync = ref.watch(contactsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Thiếp Đối Tác'),
        centerTitle: true,
        actions: [
          if (_card != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Chia sẻ vCard',
              onPressed: () => VCardGenerator.shareVCard(_card!),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loadCard,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _card == null
          ? const Center(child: Text('Không có dữ liệu'))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Huy hiệu nguồn quét
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF16A34A)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.source == 'qr'
                                  ? Icons.qr_code_2
                                  : (widget.source == 'nfc'
                                        ? Icons.nfc
                                        : Icons.verified),
                              size: 16,
                              color: const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.source == 'qr'
                                  ? 'Đã nhận danh thiếp từ mã QR'
                                  : (widget.source == 'nfc'
                                        ? 'Đã nhận danh thiếp từ chạm thẻ NFC'
                                        : 'Danh thiếp điện tử đã xác thực'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Preview danh thiếp (Template thiết kế)
                    CardPreview(card: _card!),

                    const SizedBox(height: 20),

                    // Nút LƯU VÀO VÍ DANH BẠ (Mini CRM)
                    if (isAlreadySavedInWallet)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF16A34A)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đã lưu trong Ví Danh Bạ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Bạn có thể gán nhãn và chỉnh sửa ghi chú riêng',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final matched = contactsListAsync.maybeWhen(
                                  data: (list) => list.firstWhere(
                                    (c) => c.originalCardId == _card!.id,
                                    orElse: () => list.first,
                                  ),
                                  orElse: () => null,
                                );
                                if (matched != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ContactDetailScreen(contact: matched),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Xem trong Ví'),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _showSaveToWalletBottomSheet,
                          icon: const Icon(
                            Icons.bookmark_add_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Lưu Vào Ví Danh Bạ Ứng Dụng (CRM)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Các nút phụ: Lưu vào danh bạ máy & Xuất vCard
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _handleSaveToNativeContacts,
                            icon: const Icon(
                              Icons.contact_phone_outlined,
                              size: 18,
                            ),
                            label: const Text('Lưu vào máy'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => VCardGenerator.shareVCard(_card!),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Xuất vCard'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Danh sách nút liên lạc nhanh trực tiếp
                    const Text(
                      'Liên hệ trực tiếp với đối tác',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (_card!.phone != null &&
                            _card!.phone!.isNotEmpty) ...[
                          ActionChip(
                            avatar: const Icon(
                              Icons.phone,
                              size: 18,
                              color: Colors.green,
                            ),
                            label: Text('Gọi: ${_card!.phone}'),
                            onPressed: () => _launchUrlString(
                              'tel:${_card!.phone}',
                              'phone',
                            ),
                          ),
                          ActionChip(
                            avatar: const Icon(
                              Icons.message,
                              size: 18,
                              color: Colors.blue,
                            ),
                            label: const Text('Nhắn tin SMS'),
                            onPressed: () => _launchUrlString(
                              'sms:${_card!.phone}',
                              'phone',
                            ),
                          ),
                        ],
                        if (_card!.email != null && _card!.email!.isNotEmpty)
                          ActionChip(
                            avatar: const Icon(
                              Icons.email,
                              size: 18,
                              color: Colors.red,
                            ),
                            label: Text('Email: ${_card!.email}'),
                            onPressed: () => _launchUrlString(
                              'mailto:${_card!.email}',
                              'email',
                            ),
                          ),
                        if (_card!.website != null &&
                            _card!.website!.isNotEmpty)
                          ActionChip(
                            avatar: const Icon(
                              Icons.language,
                              size: 18,
                              color: Colors.indigo,
                            ),
                            label: const Text('Website'),
                            onPressed: () =>
                                _launchUrlString(_card!.website!, 'website'),
                          ),
                        for (final link in _card!.socialLinks.where(
                          (l) => l.isVisible,
                        ))
                          ActionChip(
                            avatar: Icon(
                              link.type.icon,
                              size: 18,
                              color: const Color(0xFF2563EB),
                            ),
                            label: Text(link.label ?? link.type.displayName),
                            onPressed: () {
                              final val = link.value;
                              final typeKey = link.type.name;
                              if (link.type == SocialLinkType.phone) {
                                _launchUrlString('tel:$val', typeKey);
                              } else if (link.type == SocialLinkType.email) {
                                _launchUrlString('mailto:$val', typeKey);
                              } else {
                                _launchUrlString(
                                  val.startsWith('http') ? val : 'https://$val',
                                  typeKey,
                                );
                              }
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
    );
  }
}
