import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_editor_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/widgets/sheets/social_link_editor_sheet.dart';

/// Tab 3: Quản lý và sắp xếp các liên kết mạng xã hội (Social Links)
class CardSocialsTab extends ConsumerWidget {
  final BusinessCard initialCard;

  const CardSocialsTab({super.key, required this.initialCard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(cardEditorControllerProvider(initialCard));
    final card = editorState.card;
    final links = card.socialLinks;
    final controller = ref.read(cardEditorControllerProvider(initialCard).notifier);

    return Column(
      children: [
        // Thanh gợi ý thao tác & Nút thêm mới
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Giữ và kéo để đổi thứ tự hiển thị',
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm liên kết'),
                onPressed: () async {
                  final newLink = await SocialLinkEditorSheet.show(context: context);
                  if (newLink != null) {
                    controller.addSocialLink(newLink);
                  }
                },
              ),
            ],
          ),
        ),

        const Divider(height: 12),

        Expanded(
          child: links.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có liên kết nào',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhấn "Thêm liên kết" để gắn SĐT, Zalo, LinkedIn, GitHub...',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: links.length,
                  // ignore: deprecated_member_use
                  onReorder: (oldIndex, newIndex) {
                    controller.reorderSocialLinks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final link = links[index];
                    final meta = CardConstants.getSocialMeta(link.type.name);

                    return Card(
                      key: ValueKey(link.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: link.isVisible
                              ? Colors.grey.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      elevation: 0,
                      color: link.isVisible ? Colors.white : Colors.grey.shade100,
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_indicator, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                              child: Icon(meta.icon, size: 18, color: const Color(0xFF1E88E5)),
                            ),
                          ],
                        ),
                        title: Text(
                          link.label?.isNotEmpty == true ? link.label! : meta.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: link.isVisible ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          link.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: link.isVisible ? Colors.grey.shade700 : Colors.grey.shade400,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút ẩn/hiện
                            IconButton(
                              icon: Icon(
                                link.isVisible ? Icons.visibility : Icons.visibility_off,
                                color: link.isVisible
                                    ? const Color(0xFF1E88E5)
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              tooltip: link.isVisible ? 'Đang hiển thị' : 'Đang ẩn',
                              onPressed: () {
                                controller.updateSocialLink(
                                  link.copyWith(isVisible: !link.isVisible),
                                );
                              },
                            ),
                            // Nút sửa
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Chỉnh sửa',
                              onPressed: () async {
                                final updated = await SocialLinkEditorSheet.show(
                                  context: context,
                                  initialLink: link,
                                );
                                if (updated != null) {
                                  controller.updateSocialLink(updated);
                                }
                              },
                            ),
                            // Nút xóa
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              tooltip: 'Xóa',
                              onPressed: () {
                                controller.removeSocialLink(link.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
