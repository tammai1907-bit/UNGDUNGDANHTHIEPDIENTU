import 'package:flutter/material.dart';
import 'my_cards_screen.dart';
import 'wallet_screen.dart';
import '../scan/scan_hub_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MyCardsScreen(),
    WalletScreen(),
    ScanHubScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card, color: Color(0xFF2563EB)),
            label: 'Của Tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_shared_outlined),
            selectedIcon: Icon(Icons.folder_shared, color: Color(0xFF2563EB)),
            label: 'Ví Danh Thiếp',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner, color: Color(0xFF2563EB)),
            label: 'Quét & Thu Thập',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: Color(0xFF2563EB)),
            label: 'Thống Kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF2563EB)),
            label: 'Cài Đặt',
          ),
        ],
      ),
    );
  }
}
