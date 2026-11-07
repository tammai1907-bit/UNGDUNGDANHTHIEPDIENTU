import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/contact_service.dart';
import '../../widgets/nfc_sheet.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> with SingleTickerProviderStateMixin {
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

  void _openReadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NfcSheet(
        mode: NfcOperationMode.read,
        onDataReceived: (data, type) async {
          final walletProvider = Provider.of<WalletProvider>(context, listen: false);
          if (type == 'vCard') {
            final contact = ContactService.parseVCard(data);
            await walletProvider.addContactWithLocation(contact, fetchGps: true);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Đã nhận và lưu danh thiếp ${contact.fullName} qua NFC!'),
                  backgroundColor: const Color(0xFF16A34A),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã nhận dữ liệu qua NFC: $data')),
            );
          }
        },
      ),
    );
  }

  void _openWriteSheet(String data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NfcSheet(
        mode: NfcOperationMode.write,
        dataToWrite: data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao Tiếp Phần Cứng NFC'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(icon: Icon(Icons.download), text: 'Đọc Thẻ NFC'),
            Tab(icon: Icon(Icons.upload), text: 'Ghi Vào Thẻ NFC'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: READ NFC
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nfc, size: 72, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Thu Thập Danh Thiếp Qua NFC',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chạm mặt lưng điện thoại của bạn vào thẻ nhựa NFC hoặc điện thoại đối tác để nhận danh thiếp tức thì mà không cần quét camera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: _openReadSheet,
                    icon: const Icon(Icons.sensors),
                    label: const Text('Bắt Đầu Đọc Thẻ NFC', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: WRITE NFC
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chọn một danh thiếp bên dưới để ghi dữ liệu NDEF chuẩn vào thẻ NFC vật lý của bạn.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chọn Danh Thiếp Cần Ghi:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: cardProvider.myCards.isEmpty
                      ? const Center(child: Text('Bạn chưa có danh thiếp nào.'))
                      : ListView.separated(
                          itemCount: cardProvider.myCards.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final card = cardProvider.myCards[index];

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                    child: const Icon(Icons.credit_card, color: Color(0xFF2563EB)),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.cardName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(
                                          '${card.fullName} • ${card.company}',
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    onPressed: () => _openWriteSheet(card.toVCard()),
                                    child: const Text('Ghi Thẻ', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
