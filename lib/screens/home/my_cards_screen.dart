import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../models/business_card_model.dart';
import '../../widgets/business_card_view.dart';
import '../../widgets/qr_display_dialog.dart';
import '../../widgets/nfc_sheet.dart';
import 'card_builder_screen.dart';
import 'card_detail_screen.dart';

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
            tooltip: 'Tạo danh thiếp mới',
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardBuilderScreen()),
              );
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
                            );
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
                        const SizedBox(height: 18),

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
    if (analytics == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hiệu Quả Tương Tác',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, size: 14, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text('Trực tiếp', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatItem('Lượt Xem', '${analytics.totalViews}', Icons.visibility_outlined, const Color(0xFF2563EB)),
              _buildStatItem('Đã Lưu', '${analytics.totalSaves}', Icons.bookmark_added_outlined, const Color(0xFF16A34A)),
              _buildStatItem('Quét QR', '${analytics.qrScans}', Icons.qr_code_scanner, const Color(0xFF8B5CF6)),
              _buildStatItem('Chạm NFC', '${analytics.nfcTaps}', Icons.nfc, const Color(0xFFF97316)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Chưa có danh thiếp nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy tạo danh thiếp số đầu tiên của bạn để sẵn sàng kết nối!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CardBuilderScreen()),
                );
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
