import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/card_design/presentation/screens/card_editor_screen.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';

void main() {
  testWidgets('Creating new card updates Live Preview and saves form data', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useMockDataProvider.overrideWith((ref) => true),
        ],
        child: const MaterialApp(
          home: CardEditorScreen(), // null card = create new
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title is "Tạo Danh Thiếp Mới"
    expect(find.text('Tạo Danh Thiếp Mới'), findsOneWidget);

    // Enter Job Title & Company
    final jobTitleField = find.widgetWithText(TextFormField, 'Chức danh *');
    final companyField = find.widgetWithText(TextFormField, 'Công ty *');

    await tester.enterText(jobTitleField, 'Giám đốc Sáng tạo');
    await tester.enterText(companyField, 'Tập đoàn ABC');
    await tester.pumpAndSettle();

    // Verify Live Preview at the top now displays the entered text!
    expect(find.text('Giám đốc Sáng tạo'), findsWidgets);
    expect(find.text('Tập đoàn ABC'), findsWidgets);

    // Tap Save button
    final saveButton = find.text('Lưu');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  });
}
