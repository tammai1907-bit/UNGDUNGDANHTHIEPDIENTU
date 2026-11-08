import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/config/app_constants.dart';
import 'package:digital_business_card/models/business_card_model.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/domain/entities/card_design.dart';
import 'package:digital_business_card/features/card_design/data/models/card_sync_mapper.dart';
import 'package:digital_business_card/widgets/business_card_view.dart';

void main() {
  group('Theme Color & Card Sync Tests', () {
    test('AppConstants.getThemeColorById parses custom hex color correctly', () {
      final theme = AppConstants.getThemeColorById('#8BC34A');
      expect(theme['primary'], const Color(0xFF8BC34A));
    });

    test('AppConstants.getThemeColorById parses JSON design color correctly', () {
      final jsonStr = jsonEncode({
        'primary': '#8BC34A',
        'secondary': '#3B82F6',
        'text': '#0F172A',
      });
      final theme = AppConstants.getThemeColorById(jsonStr);
      expect(theme['primary'], const Color(0xFF8BC34A));
      expect(theme['secondary'], const Color(0xFF3B82F6));
      expect(theme['textColor'], const Color(0xFF0F172A));
    });

    test('CardSyncMapper preserves custom colors and banner/avatar', () {
      final card = BusinessCard(
        id: 'test_card',
        ownerId: 'demo_user',
        cardName: 'Thẻ Test',
        fullName: 'Mai Văn Tâm',
        jobTitle: 'Kỹ sư Phần mềm',
        company: 'TechCorp',
        avatarUrl: '/path/to/cat.jpg',
        bannerUrl: '/path/to/banner.jpg',
        design: CardDesign.fromHex(
          templateId: 'modern',
          primaryColorHex: '#8BC34A',
          secondaryColorHex: '#3B82F6',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = CardSyncMapper.toModel(card);
      expect(model.avatarUrl, '/path/to/cat.jpg');
      expect(model.coverUrl, '/path/to/banner.jpg');
      expect(model.themeColorId, contains('#8BC34A'));

      final restored = CardSyncMapper.toDomain(model);
      expect(restored.fullName, 'Mai Văn Tâm');
      expect(restored.avatarUrl, '/path/to/cat.jpg');
      expect(restored.bannerUrl, '/path/to/banner.jpg');
      expect(restored.design.primaryColorHex, '#8BC34A');
      expect(restored.design.secondaryColorHex, '#3B82F6');
    });

    testWidgets('BusinessCardView renders without errors with custom hex theme', (tester) async {
      final model = BusinessCardModel(
        id: 'test_01',
        userId: 'demo_user',
        cardName: 'Công Việc Chính Thức',
        fullName: 'Mai Văn Tâm',
        jobTitle: 'Sinh vien hutech',
        company: 'Đại học Công Nghệ',
        phone: '0987654321',
        email: 'tammai1907@gmail.com',
        themeColorId: '#8BC34A',
        template: CardTemplateType.modern,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusinessCardView(card: model),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mai Văn Tâm'), findsOneWidget);
      expect(find.text('Sinh vien hutech'), findsOneWidget);
    });
  });
}
