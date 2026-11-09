import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'config/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/card_provider.dart';
import 'providers/wallet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đặt thanh trạng thái trong suốt mượt mà
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => CardProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => WalletProvider()),
        ],
        child: const DigitalBusinessCardApp(),
      ),
    ),
  );
}

class DigitalBusinessCardApp extends ConsumerWidget {
  const DigitalBusinessCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Danh Thiếp Điện Tử',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
