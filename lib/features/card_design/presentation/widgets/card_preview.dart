import 'package:flutter/material.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'templates/template_registry.dart';

/// Widget xem trước danh thiếp theo thời gian thực (Live Preview)
class CardPreview extends StatelessWidget {
  final BusinessCard card;
  final bool isInteractive;
  final double? maxWidth;

  const CardPreview({
    super.key,
    required this.card,
    this.isInteractive = true,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = TemplateRegistry.buildCard(
      card: card,
      isInteractive: isInteractive,
    );

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }

    return content;
  }
}
