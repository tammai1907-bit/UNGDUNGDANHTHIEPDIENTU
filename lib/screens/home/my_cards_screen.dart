import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../models/business_card_model.dart';
import '../../widgets/business_card_view.dart';
import '../../widgets/qr_display_dialog.dart';
import '../../widgets/nfc_sheet.dart';
import 'card_detail_screen.dart';
import '../../features/card_design/presentation/screens/my_cards_screen.dart' as card_design;
import '../../features/card_design/presentation/screens/card_editor_screen.dart';
import '../../features/card_design/data/models/card_sync_mapper.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  void _showQr(BuildContext context, BusinessCardModel card) {
    showDialog(
      context: context,
      builder: (_) => QrDisplayDialog(
        card: card,
        onWriteNfc: () => _openNfcWrite(context, card),
      ),
    );
  }

  void _openNfcWrite(BuildContext context, BusinessCardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NfcSheet(
        mode: NfcOperationMode.write,
        dataToWrite: card.toVCard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Thiếp Của Tôi'),
        actions: [
          IconButton(
            tooltip: 'Phân hệ Thiết kế & Quản lý Danh thiếp (Thành viên 2)',
            icon: const Icon(Icons.palette_outlined, color: Color(0xFF1E88E5), size: 26),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const card_design.MyCardsScreen()),
              );
              if (context.mounted) {
                cardProvider.loadMyCards();
              }
            },
          ),
          IconButton(
            tooltip: 'Tạo danh thiếp mới',
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 28),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardEditorScreen()),
              );
              if (context.mounted) {
                cardProvider.loadMyCards();
              }
            },
          ),
        ],
      ),
      body: cardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cardProvider.myCards.isEmpty
              ? _buildEmptyState(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Multi-profile selector chips
                      const Text(
                        'Đa Hồ Sơ (Multi-Profile):',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cardProvider.myCards.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final card = cardProvider.myCards[index];
                            final isActive = cardProvider.activeCard?.id == card.id;

                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (card.isDefault) ...[
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(card.cardName),
                                ],
                              ),
                              selected: isActive,
                              selectedColor: const Color(0xFF2563EB),
                              labelStyle: TextStyle(
                                color: isActive ? Colors.white : const Color(0xFF334155),
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              onSelected: (_) => cardProvider.setActiveCard(card),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Active Card Preview
                      if (cardProvider.activeCard != null) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CardDetailScreen(card: cardProvider.activeCard!),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                cardProvider.loadMyCards();
                              }
                            });
                          },
                          child: BusinessCardView(
                            card: cardProvider.activeCard!,
                            onSocialClick: (platform) {
                              cardProvider.recordInteraction(
                                cardId: cardProvider.activeCard!.id,
                                platform: platform,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Nút chỉnh sửa nhanh danh thiếp
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB)),
                            label: const Text(
                              'Chỉnh sửa thông tin & Giao diện thẻ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CardEditorScreen(
                                    card: CardSyncMapper.toDomain(cardProvider.activeCard!),
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                cardProvider.loadMyCards();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick sharing shortcuts
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => _showQr(context, cardProvider.activeCard!),
                                icon: const Icon(Icons.qr_code, size: 20),
                                label: const Text('Mã QR Nhanh'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => _openNfcWrite(context, cardProvider.activeCard!),
                                icon: const Icon(Icons.nfc, size: 20),
                                label: const Text('Chạm Ghi NFC'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Analytics quick summary card
                        _buildQuickAnalytics(context, cardProvider),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuickAnalytics(BuildContext context, CardProvider cardProvider) {
    final analytics = cardProvider.activeAnalytics;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hiệu Quả Tương Tác',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, size: 14, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Trực tiếp',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.remove_red_eye_outlined,
                color: const Color(0xFF2563EB),
                value: '${analytics?.totalViews ?? 0}',
                label: 'Lượt Xem',
              ),
              _buildStatItem(
                icon: Icons.bookmark_border,
                color: const Color(0xFF10B981),
                value: '${analytics?.totalSaves ?? 0}',
                label: 'Lưu Danh Bạ',
              ),
              _buildStatItem(
                icon: Icons.qr_code_scanner,
                color: const Color(0xFF8B5CF6),
                value: '${analytics?.qrScans ?? 0}',
                label: 'Quét QR',
              ),
              _buildStatItem(
                icon: Icons.nfc,
                color: const Color(0xFFF97316),
                value: '${analytics?.nfcTaps ?? 0}',
                label: 'Chạm NFC',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card_outlined, size: 64, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có danh thiếp nào',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo danh thiếp đầu tiên để bắt đầu kết nối chuyên nghiệp qua QR Code và NFC.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CardEditorScreen()),
                );
                if (context.mounted) {
                  Provider.of<CardProvider>(context, listen: false).loadMyCards();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo Danh Thiếp Ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
