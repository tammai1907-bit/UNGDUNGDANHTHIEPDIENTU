import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'package:digital_business_card/core/widgets/app_loading_shimmer.dart';
import 'package:digital_business_card/core/widgets/app_snackbar.dart';
import 'package:digital_business_card/core/widgets/confirm_dialog.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/card_preview.dart';
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

                // Menu 3 chấm (Sửa, Nhân bản, Đặt mặc định, Xóa)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) async {
                    switch (val) {
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

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
