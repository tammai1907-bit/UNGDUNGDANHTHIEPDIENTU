import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/domain/entities/card_design.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_repository_provider.dart';
import 'package:digital_business_card/features/sharing/presentation/screens/share_screen.dart';
import 'package:digital_business_card/features/sharing/services/gallery_saver_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    GallerySaverService.saveImageOverride = null;
  });

  final testCard = BusinessCard(
    id: 'card_official_01',
    ownerId: 'user_current',
    cardName: 'Công Việc Chính Thức',
    fullName: 'Mai Văn Tâm',
    jobTitle: 'Kỹ sư Phần mềm Cấp cao',
    company: 'TechCorp',
    phone: '0987654321',
    email: 'tammai1907@gmail.com',
    design: CardDesign.fromHex(
      templateId: 'modern',
      primaryColorHex: '#2563EB',
      secondaryColorHex: '#3B82F6',
      backgroundColorHex: '#FFFFFF',
      textColorHex: '#0F172A',
    ),
    isDefault: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  Widget buildTestWidget({Future<Uint8List?> Function()? captureQrOverride}) {
    return ProviderScope(
      overrides: [
        useMockDataProvider.overrideWith((ref) => true),
        myCardsStreamProvider.overrideWith((ref) => Stream.value([testCard])),
      ],
      child: MaterialApp(
        home: ShareScreen(captureQrOverride: captureQrOverride),
      ),
    );
  }

  void setPhoneScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('ShareScreen Widget Tests', () {
    testWidgets('Hiển thị domain mới https://card.maitam1907.dev và dải chia sẻ nhanh',
        (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('https://card.maitam1907.dev/c/user_current/card_official_01'),
        findsOneWidget,
      );
      expect(find.text('Chia sẻ nhanh qua ứng dụng'), findsOneWidget);
      expect(find.text('Messenger'), findsOneWidget);
      expect(find.text('Zalo'), findsWidgets);
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
    });

    testWidgets('Nhấn Chia Sẻ Link mở bảng đa ứng dụng phổ biến', (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Chia Sẻ Link'));
      await tester.tap(find.text('Chia Sẻ Link'));
      await tester.pumpAndSettle();

      expect(find.text('Gửi qua ứng dụng phổ biến'), findsOneWidget);
      expect(find.text('TikTok'), findsWidgets);
      expect(find.text('Telegram'), findsWidgets);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Gmail'), findsOneWidget);
      expect(find.text('Tin nhắn'), findsOneWidget);
      expect(find.text('LinkedIn'), findsOneWidget);
    });

    testWidgets('Nhấn Xuất vCard hiển thị nút "Lưu vào Danh bạ điện thoại"',
        (tester) async {
      setPhoneScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Xuất vCard'));
      await tester.tap(find.text('Xuất vCard'));
      await tester.pumpAndSettle();

      expect(find.text('Lưu vào Danh bạ điện thoại'), findsOneWidget);
      expect(find.text('Lưu vào Danh bạ Điện thoại máy'), findsNothing);
    });

    testWidgets('Nhấn Lưu Ảnh QR lưu ảnh và hiện thông báo "Đã lưu về photo"',
        (tester) async {
      String? savedFileName;
      GallerySaverService.saveImageOverride = (bytes, fileName) async {
        savedFileName = fileName;
        return 'content://media/external/images/media/1';
      };

      setPhoneScreenSize(tester);
      await tester.pumpWidget(
        buildTestWidget(
          captureQrOverride: () async =>
              Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Lưu Ảnh QR'));
      await tester.tap(find.text('Lưu Ảnh QR'));
      await tester.pumpAndSettle();

      expect(savedFileName, startsWith('QR_card_official_01_'));
      expect(find.text('Đã lưu về photo'), findsOneWidget);
    });
  });
}
