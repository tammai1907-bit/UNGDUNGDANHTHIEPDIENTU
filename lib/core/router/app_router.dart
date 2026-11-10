import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/onboarding_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/card_design/domain/entities/business_card.dart';
import '../../features/card_design/presentation/screens/my_cards_screen.dart';
import '../../features/card_design/presentation/screens/card_editor_screen.dart';
import '../../features/sharing/presentation/screens/share_screen.dart';
import '../../features/sharing/presentation/screens/qr_scanner_screen.dart';
import '../../features/sharing/presentation/screens/public_card_screen.dart';
import '../../features/contacts/presentation/screens/contact_wallet_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../widgets/main_shell.dart';

/// Lớp chuyển đổi Stream thành Listenable để GoRouter tự động chuyển hướng khi trạng thái Auth đổi
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provider cung cấp GoRouter toàn cục kết hợp kiểm tra trạng thái đăng nhập
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authRepo.authStateChanges),
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) return null;

      final hasSeenOnboarding = ref.read(onboardingProvider);
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (!hasSeenOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      final isLoggedIn = authRepo.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute && !isOnboarding) {
        return '/login';
      }

      if (isLoggedIn && (isAuthRoute || isOnboarding)) {
        return '/';
      }

      return null;
    },
    routes: [
      // Màn hình Khởi động (Splash)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Màn hình Hướng dẫn (Onboarding)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Màn hình Đăng nhập
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Màn hình Đăng ký
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Màn hình Quên mật khẩu
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Màn hình Hồ sơ tài khoản gốc
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Màn hình Cài đặt & Quyền riêng tư
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Trình chỉnh sửa danh thiếp (tái sử dụng từ features/card_design)
      GoRoute(
        path: '/editor',
        name: 'card_editor',
        builder: (context, state) {
          final card = state.extra as BusinessCard?;
          return CardEditorScreen(card: card);
        },
      ),
      GoRoute(
        path: '/create-card',
        name: 'create_card',
        builder: (context, state) => const CardEditorScreen(card: null),
      ),

      // Quét mã QR bằng Camera
      GoRoute(
        path: '/scan-qr',
        name: 'scan_qr',
        builder: (context, state) => const QrScannerScreen(),
      ),

      // Xem danh thiếp công khai
      GoRoute(
        path: '/public-card',
        name: 'public_card',
        builder: (context, state) {
          final ownerId = state.uri.queryParameters['ownerId'] ?? 'user_current';
          final cardId = state.uri.queryParameters['cardId'] ?? '';
          final source = state.uri.queryParameters['source'] ?? 'direct';
          return PublicCardScreen(ownerId: ownerId, cardId: cardId, source: source);
        },
      ),

      // Khung Bottom Navigation Bar 4 Tab thông qua StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Thẻ Của Tôi (Phân hệ card_design đã hoàn thiện)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'my_cards',
                builder: (context, state) => const MyCardsScreen(),
              ),
            ],
          ),

          // Tab 1: Chia Sẻ (Phân hệ B)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/share',
                name: 'share',
                builder: (context, state) => const ShareScreen(),
              ),
            ],
          ),

          // Tab 2: Danh Bạ (Phân hệ C)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contacts',
                name: 'contacts',
                builder: (context, state) => const ContactWalletScreen(),
              ),
            ],
          ),

          // Tab 3: Thống Kê (Phân hệ C)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                name: 'analytics',
                builder: (context, state) => const AnalyticsDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
