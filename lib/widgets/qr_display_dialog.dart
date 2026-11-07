import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/business_card_model.dart';
import '../services/share_service.dart';

class QrDisplayDialog extends StatefulWidget {
  final BusinessCardModel card;
  final VoidCallback? onWriteNfc;

  const QrDisplayDialog({
    super.key,
    required this.card,
    this.onWriteNfc,
  });

  @override
  State<QrDisplayDialog> createState() => _QrDisplayDialogState();
}

class _QrDisplayDialogState extends State<QrDisplayDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vcardData = widget.card.toVCard();
    final onlineUrl = widget.card.website.isNotEmpty
        ? widget.card.website
        : 'https://smartcard.app/p/${widget.card.id}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chia Sẻ Danh Thiếp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      widget.card.cardName,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tabs Online vs Offline
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: '⚡ QR Tĩnh (Offline vCard)'),
                  Tab(text: '🌐 QR Động (Online URL)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QR Content
            SizedBox(
              height: 250,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Offline vCard QR
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImageView(
                        data: vcardData,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '✓ Quét bằng camera máy thường lưu thẳng vào danh bạ (Không cần mạng)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  // Tab 2: Online Link QR
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImageView(
                        data: onlineUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Đường dẫn: $onlineUrl',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons: vCard File, NFC, Share
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ShareService.instance.shareVCardFile(widget.card);
                    },
                    icon: const Icon(Icons.contact_page_outlined, size: 18),
                    label: const Text('Gửi .vcf', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.onWriteNfc != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onWriteNfc?.call();
                      },
                      icon: const Icon(Icons.nfc, size: 18),
                      label: const Text('Ghi NFC', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
