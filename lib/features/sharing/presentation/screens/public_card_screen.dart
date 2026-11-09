import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/domain/entities/social_link.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/card_preview.dart';
import 'package:digital_business_card/features/card_design/data/datasources/card_seed_data.dart';
import 'package:digital_business_card/features/sharing/utils/vcard_generator.dart';

class PublicCardScreen extends ConsumerStatefulWidget {
  final String ownerId;
  final String cardId;

  const PublicCardScreen({
    super.key,
    required this.ownerId,
    required this.cardId,
  });

  @override
  ConsumerState<PublicCardScreen> createState() => _PublicCardScreenState();
}

class _PublicCardScreenState extends ConsumerState<PublicCardScreen> {
  bool _isLoading = true;
  BusinessCard? _card;
  String? _errorMessage;

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
      final res = await repository.getCardById(userId: widget.ownerId, cardId: widget.cardId);
      final fetched = res.dataOrNull;

      if (fetched != null) {
        setState(() {
          _card = fetched;
          _isLoading = false;
        });
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải danh thiếp: $e';
      });
    }
  }

  Future<void> _launchUrlString(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở liên kết: $urlStr')),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _handleSaveToContacts() async {
    if (_card == null) return;
    final success = await VCardGenerator.saveToDeviceContacts(_card!);
    if (!mounted) return;

    if (success) {
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
          content: Text('Không thể lưu vào danh bạ (Vui lòng cấp quyền truy cập danh bạ)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Thiếp Điện Tử'),
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
                      FilledButton(onPressed: _loadCard, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : _card == null
                  ? const Center(child: Text('Không có dữ liệu'))
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Huy hiệu trực tuyến
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 16, color: Color(0xFF16A34A)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Danh thiếp điện tử đã xác thực',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Preview danh thiếp
                            CardPreview(card: _card!),

                            const SizedBox(height: 24),

                            // Nút hành động chính
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: _handleSaveToContacts,
                                    icon: const Icon(Icons.person_add_alt_1),
                                    label: const Text('Lưu Vào Danh Bạ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: () => VCardGenerator.shareVCard(_card!),
                                  icon: const Icon(Icons.download_rounded),
                                  label: const Text('Xuất vCard'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Danh sách nút liên lạc nhanh
                            const Text(
                              'Liên hệ trực tiếp',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                if (_card!.phone != null && _card!.phone!.isNotEmpty) ...[
                                  ActionChip(
                                    avatar: const Icon(Icons.phone, size: 18, color: Colors.green),
                                    label: Text('Gọi: ${_card!.phone}'),
                                    onPressed: () => _launchUrlString('tel:${_card!.phone}'),
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.message, size: 18, color: Colors.blue),
                                    label: const Text('Nhắn tin SMS'),
                                    onPressed: () => _launchUrlString('sms:${_card!.phone}'),
                                  ),
                                ],
                                if (_card!.email != null && _card!.email!.isNotEmpty)
                                  ActionChip(
                                    avatar: const Icon(Icons.email, size: 18, color: Colors.red),
                                    label: Text('Email: ${_card!.email}'),
                                    onPressed: () => _launchUrlString('mailto:${_card!.email}'),
                                  ),
                                if (_card!.website != null && _card!.website!.isNotEmpty)
                                  ActionChip(
                                    avatar: const Icon(Icons.language, size: 18, color: Colors.indigo),
                                    label: const Text('Website'),
                                    onPressed: () => _launchUrlString(_card!.website!),
                                  ),
                                for (final link in _card!.socialLinks.where((l) => l.isVisible))
                                  ActionChip(
                                    avatar: Icon(link.type.icon, size: 18, color: const Color(0xFF2563EB)),
                                    label: Text(link.label ?? link.type.displayName),
                                    onPressed: () {
                                      final val = link.value;
                                      if (link.type == SocialLinkType.phone) {
                                        _launchUrlString('tel:$val');
                                      } else if (link.type == SocialLinkType.email) {
                                        _launchUrlString('mailto:$val');
                                      } else {
                                        _launchUrlString(val.startsWith('http') ? val : 'https://$val');
                                      }
                                    },
                                  ),
                              ],
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
