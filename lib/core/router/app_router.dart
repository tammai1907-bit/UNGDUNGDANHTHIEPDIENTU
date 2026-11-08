import 'package:go_router/go_router.dart';
import '../../features/card_design/domain/entities/business_card.dart';
import '../../features/card_design/presentation/screens/my_cards_screen.dart';
import '../../features/card_design/presentation/screens/card_editor_screen.dart';

/// Cấu hình định tuyến GoRouter cho Phân hệ Quản lý & Thiết kế Danh thiếp
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'my_cards',
      builder: (context, state) => const MyCardsScreen(),
    ),
    GoRoute(
      path: '/editor',
      name: 'card_editor',
      builder: (context, state) {
        final card = state.extra as BusinessCard?;
        return CardEditorScreen(card: card);
      },
    ),
  ],
);
