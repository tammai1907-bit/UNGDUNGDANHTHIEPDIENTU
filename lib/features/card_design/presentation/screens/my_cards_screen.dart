import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:digital_business_card/config/app_constants.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'package:digital_business_card/core/widgets/app_loading_shimmer.dart';
import 'package:digital_business_card/core/widgets/app_snackbar.dart';
import 'package:digital_business_card/core/widgets/confirm_dialog.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/card_preview.dart';
import 'package:digital_business_card/features/sharing/utils/vcard_generator.dart';
import 'card_editor_screen.dart';

/// Màn hình "Danh sách thẻ của tôi" (My Cards Screen)
class MyCardsScreen extends ConsumerWidget {
  const MyCardsScreen({super.key});

  void _openEditor(BuildContext context, [BusinessCard? card]) {
    try {
      context.push('/editor', extra: card);
    } catch (_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CardEditorScreen(card: card)),
      );
    }
  }

  void _showCardQrDialog(BuildContext context, BusinessCard card) {
    final shareUrl = AppConstants.buildCardShareUrl(
      ownerId: card.ownerId.isNotEmpty ? card.ownerId : 'user_current',
      cardId: card.id,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(
                    card.cardName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                card.fullName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: shareUrl,
                  version: QrVersions.auto,
                  size: 200,
                  gapless: true,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quét mã QR để xem và lưu danh thiếp',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/share');
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Chia Sẻ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        VCardGenerator.shareVCard(card);
                      },
                      icon: const Icon(Icons.contact_phone_rounded, size: 18),
                      label: const Text('Xuất vCard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(myCardsStreamProvider);
    final useMock = ref.watch(useMockDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh Thiếp Của Tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Switch chuyển đổi Mock / Firebase nhanh để kiểm thử
          Row(
            children: [
              Text(
                useMock ? 'Mock' : 'Firebase',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: useMock,
                activeThumbColor: Colors.amber,
                onChanged: (val) {
                  ref.read(useMockDataProvider.notifier).state = val;
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) => _buildCardList(context, ref, cards),
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 2,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: AppLoadingShimmer(height: 200, borderRadius: 16),
          ),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Đã xảy ra lỗi: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.refresh(myCardsStreamProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: cardsAsync.maybeWhen(
        data: (cards) {
          final isMaxReached = cards.length >= CardConstants.maxCardsPerUser;

          return FloatingActionButton.extended(
            onPressed: isMaxReached
                ? () {
                    AppSnackBar.showError(
                      context,
                      'Bạn đã đạt giới hạn tối đa ${CardConstants.maxCardsPerUser} thẻ.',
                    );
                  }
                : () => _openEditor(context),
            backgroundColor: isMaxReached ? Colors.grey : const Color(0xFF1E88E5),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              isMaxReached
                  ? 'Đạt giới hạn (${cards.length}/${CardConstants.maxCardsPerUser})'
                  : 'Thêm danh thiếp',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, WidgetRef ref, List<BusinessCard> cards) {
    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  size: 64,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bạn chưa có danh thiếp nào',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tạo ngay danh thiếp đầu tiên để chia sẻ thông tin chuyên nghiệp của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tạo Danh Thiếp Đầu Tiên'),
                onPressed: () => _openEditor(context),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        // Thanh thông tin số lượng thẻ
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đa Hồ Sơ (${cards.length}/${CardConstants.maxCardsPerUser} thẻ)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                'Chạm 3 chấm để tùy chọn',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        ...cards.map((card) => _buildCardItem(context, ref, card, cards.length)),
      ],
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref,
    BusinessCard card,
    int totalCards,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(card.design.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thanh header tên thẻ & nút 3 chấm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                if (card.isDefault)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade900),
                        const SizedBox(width: 4),
                        Text(
                          'Mặc định',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: Text(
                    card.cardName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                // Menu 3 chấm (Xem QR, Sửa, Nhân bản, Đặt mặc định, Xóa)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) async {
                    switch (val) {
                      case 'qr':
                        _showCardQrDialog(context, card);
                        break;
                      case 'edit':
                        _openEditor(context, card);
                        break;
                      case 'duplicate':
                        if (totalCards >= CardConstants.maxCardsPerUser) {
                          AppSnackBar.showError(
                            context,
                            'Đã đạt tối đa ${CardConstants.maxCardsPerUser} thẻ, không thể nhân bản thêm.',
                          );
                          return;
                        }
                        final ok = await ref
                            .read(cardListControllerProvider.notifier)
                            .duplicateCard(card.id);
                        if (ok && context.mounted) {
                          AppSnackBar.showSuccess(context, 'Đã nhân bản danh thiếp');
                        }
                        break;
                      case 'set_default':
                        final ok = await ref
                            .read(cardListControllerProvider.notifier)
                            .setDefaultCard(card.id);
                        if (ok && context.mounted) {
                          AppSnackBar.showSuccess(
                            context,
                            'Đã đặt "${card.cardName}" làm danh thiếp mặc định',
                          );
                        }
                        break;
                      case 'delete':
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          title: 'Xóa danh thiếp',
                          content:
                              'Bạn có chắc chắn muốn xóa danh thiếp "${card.cardName}"? Hành động này không thể hoàn tác.',
                          confirmText: 'Xóa',
                          isDestructive: true,
                        );
                        if (confirmed == true) {
                          final ok = await ref
                              .read(cardListControllerProvider.notifier)
                              .deleteCard(card.id);
                          if (ok && context.mounted) {
                            AppSnackBar.showSuccess(context, 'Đã xóa danh thiếp');
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'qr',
                      child: Row(
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 20, color: Color(0xFF2563EB)),
                          SizedBox(width: 10),
                          Text('Xem mã QR'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1E88E5)),
                          SizedBox(width: 10),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Nhân bản'),
                        ],
                      ),
                    ),
                    if (!card.isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline_rounded, size: 20, color: Colors.amber),
                            SizedBox(width: 10),
                            Text('Đặt làm mặc định'),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Xóa danh thiếp', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bản xem trước (Live Card Preview)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: CardPreview(card: card, isInteractive: true),
          ),

          // Thanh nút tương tác nhanh bên dưới thẻ
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showCardQrDialog(context, card),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF2563EB)),
                    label: const Text('Mã QR', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => context.push('/share'),
                    icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF16A34A)),
                    label: const Text('Chia Sẻ', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _openEditor(context, card),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Sửa', style: TextStyle(fontSize: 12)),
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
