import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digital_business_card/features/card_design/presentation/screens/my_cards_screen.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('MyCardsScreen builds and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          useMockDataProvider.overrideWith((ref) => true),
        ],
        child: const MaterialApp(
          home: MyCardsScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify title is rendered
    expect(find.text('Danh Thiếp Của Tôi'), findsOneWidget);
  });
}
