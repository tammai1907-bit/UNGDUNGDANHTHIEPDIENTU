import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/core/widgets/app_snackbar.dart';
import 'package:digital_business_card/core/widgets/confirm_dialog.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_editor_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/card_preview.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/editor_tabs/card_info_tab.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/editor_tabs/card_design_tab.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/editor_tabs/card_socials_tab.dart';

/// Màn hình Trình chỉnh sửa danh thiếp (Card Editor Screen) với Live Preview
class CardEditorScreen extends ConsumerStatefulWidget {
  final BusinessCard? card;

  const CardEditorScreen({super.key, this.card});

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final editorState = ref.read(cardEditorControllerProvider(widget.card));
    if (!editorState.isDirty) return true;

    final shouldLeave = await ConfirmDialog.show(
      context: context,
      title: 'Hủy các thay đổi?',
      content: 'Bạn có những thay đổi chưa được lưu. Nếu thoát bây giờ, các chỉnh sửa sẽ bị mất.',
      confirmText: 'Rời khỏi',
      cancelText: 'Tiếp tục sửa',
      isDestructive: true,
    );

    return shouldLeave;
  }

  Future<void> _handleSave() async {
    final controller = ref.read(cardEditorControllerProvider(widget.card).notifier);
    final ok = await controller.saveCard();

    if (ok && mounted) {
      AppSnackBar.showSuccess(context, 'Đã lưu danh thiếp thành công!');
      Navigator.pop(context);
    } else if (mounted) {
      final err = ref.read(cardEditorControllerProvider(widget.card)).errorMessage;
      if (err != null) {
        AppSnackBar.showError(context, err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(cardEditorControllerProvider(widget.card));
    final isNew = editorState.isNew;
    final isSaving = editorState.isSaving;

    return PopScope(
      canPop: !editorState.isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNew ? 'Tạo Danh Thiếp Mới' : 'Chỉnh Sửa Danh Thiếp',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: isSaving ? null : _handleSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 18),
                label: const Text('Lưu'),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Màn hình rộng (tablet hoặc ngang): hiển thị 2 cột
            if (constraints.maxWidth >= 768) {
              return _buildWideLayout(editorState);
            }
            // Điện thoại: hiển thị preview ghim phía trên + tab bên dưới
            return _buildMobileLayout(editorState);
          },
        ),
      ),
    );
  }

  /// Bố cục cho điện thoại di động
  Widget _buildMobileLayout(CardEditorState state) {
    return Column(
      children: [
        // Khung Live Preview ghim phía trên
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF1E88E5)),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Xem trước thời gian thực (Live Preview)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E88E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isDirty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Chưa lưu',
                        style: TextStyle(fontSize: 10, color: Colors.amber.shade900),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Card preview cuộn ngang hoặc tự co dãn
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  child: CardPreview(card: state.card, isInteractive: false),
                ),
              ),
            ],
          ),
        ),

        // Tab bar bên dưới
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1E88E5),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF1E88E5),
            tabs: const [
              Tab(icon: Icon(Icons.person_outline, size: 20), text: 'Thông tin'),
              Tab(icon: Icon(Icons.palette_outlined, size: 20), text: 'Giao diện'),
              Tab(icon: Icon(Icons.share_outlined, size: 20), text: 'Liên kết'),
            ],
          ),
        ),

        // Nội dung từng Tab
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              CardInfoTab(card: widget.card),
              CardDesignTab(card: widget.card),
              CardSocialsTab(card: widget.card),
            ],
          ),
        ),
      ],
    );
  }

  /// Bố cục cho màn hình rộng / Tablet (2 cột)
  Widget _buildWideLayout(CardEditorState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột trái: Form nhập liệu có Tab
        Expanded(
          flex: 6,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1E88E5),
                indicatorColor: const Color(0xFF1E88E5),
                tabs: const [
                  Tab(icon: Icon(Icons.person_outline), text: 'Thông tin'),
                  Tab(icon: Icon(Icons.palette_outlined), text: 'Giao diện & Template'),
                  Tab(icon: Icon(Icons.share_outlined), text: 'Liên kết xã hội'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CardInfoTab(card: widget.card),
                    CardDesignTab(card: widget.card),
                    CardSocialsTab(card: widget.card),
                  ],
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1),

        // Cột phải: Live Preview ghim cố định
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined, color: Color(0xFF1E88E5)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Xem trước theo thời gian thực (Live Preview)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CardPreview(card: state.card, isInteractive: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
