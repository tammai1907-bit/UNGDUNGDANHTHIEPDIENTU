import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../models/business_card_model.dart';
import '../../providers/card_provider.dart';
import '../../widgets/business_card_view.dart';
import '../../widgets/qr_display_dialog.dart';
import '../../widgets/virtual_bg_dialog.dart';
import '../../widgets/nfc_sheet.dart';
import '../../services/share_service.dart';
import '../../features/card_design/presentation/screens/card_editor_screen.dart';
import '../../features/card_design/data/models/card_sync_mapper.dart';

class CardDetailScreen extends StatefulWidget {
  final BusinessCardModel card;

  const CardDetailScreen({super.key, required this.card});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late bool _hidePhone;
  late bool _hideEmail;

  @override
  void initState() {
    super.initState();
    _hidePhone = widget.card.isPrivatePhone;
    _hideEmail = widget.card.isPrivateEmail;
  }

  void _showQrDialog(BusinessCardModel currentCard) {
    showDialog(
      context: context,
      builder: (_) => QrDisplayDialog(
        card: currentCard,
        onWriteNfc: () => _openNfcWrite(currentCard),
      ),
    );
  }

  void _openNfcWrite(BusinessCardModel currentCard) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NfcSheet(
        mode: NfcOperationMode.write,
        dataToWrite: currentCard.toVCard(),
      ),
    );
  }

  void _openVirtualBgDialog(BusinessCardModel currentCard) {
    showDialog(
      context: context,
      builder: (_) => VirtualBgDialog(card: currentCard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    // Lấy card mới nhất từ provider nếu có update
    final currentCard = cardProvider.myCards.firstWhere(
      (c) => c.id == widget.card.id,
      orElse: () => widget.card,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCard.cardName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => CardEditorScreen(card: CardSyncMapper.toDomain(currentCard)))); if (mounted) { cardProvider.loadMyCards(); }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: const Text('Bạn có chắc muốn xóa danh thiếp này không?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () async {
                        final parentNav = Navigator.of(context);
                        Navigator.pop(ctx);
                        await cardProvider.deleteCard(currentCard.id);
                        if (mounted) parentNav.pop();
                      },
                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screenshot wrapper around BusinessCardView
            Screenshot(
              controller: _screenshotController,
              child: BusinessCardView(
                card: currentCard,
                onSocialClick: (platform) {
                  cardProvider.recordInteraction(cardId: currentCard.id, platform: platform);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Share & Hardware Actions Grid
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _showQrDialog(currentCard),
                    icon: const Icon(Icons.qr_code, size: 20),
                    label: const Text('Mã QR Code'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _openNfcWrite(currentCard),
                    icon: const Icon(Icons.nfc, size: 20),
                    label: const Text('Chạm Ghi NFC'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ShareService.instance.captureAndShareCardImage(
                        _screenshotController,
                        currentCard.fullName,
                      );
                    },
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('Xuất Ảnh PNG'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openVirtualBgDialog(currentCard),
                    icon: const Icon(Icons.video_camera_front_outlined, size: 18),
                    label: const Text('Phông Nền Zoom'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chế độ bảo mật (Privacy Mode Toggle)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chế Độ Bảo Mật Thông Tin (Privacy Toggle)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ẩn thông tin nhạy cảm khi chia sẻ công khai. Người nhận chỉ thấy khi bạn cho phép hoặc gửi yêu cầu kết nối 2 chiều.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ẩn Số Điện Thoại Cá Nhân', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _hidePhone,
                    onChanged: (val) {
                      setState(() => _hidePhone = val);
                      cardProvider.togglePrivacy(cardId: currentCard.id, hidePhone: val);
                    },
                  ),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ẩn Địa Chỉ Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _hideEmail,
                    onChanged: (val) {
                      setState(() => _hideEmail = val);
                      cardProvider.togglePrivacy(cardId: currentCard.id, hideEmail: val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Thông tin chi tiết vCard
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dữ liệu chuẩn vCard 3.0 (Offline-first):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      currentCard.toVCard(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF00FF66),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
