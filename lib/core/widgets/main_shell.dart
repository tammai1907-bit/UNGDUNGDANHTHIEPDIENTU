import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// Khung ứng dụng chính chứa Bottom Navigation Bar 4 Tab và ShellRoute
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.contact_emergency_rounded, color: Color(0xFF1E88E5), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              navigationShell.currentIndex == 0
                  ? 'Thẻ Của Tôi'
                  : navigationShell.currentIndex == 1
                      ? 'Chia Sẻ Danh Thiếp'
                      : navigationShell.currentIndex == 2
                          ? 'Ví Danh Bạ'
                          : 'Thống Kê Tương Tác',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Hồ sơ tài khoản',
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.15),
              backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                  ? Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                    )
                  : null,
            ),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            tooltip: 'Cài đặt & Quyền riêng tư',
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (idx) => _onTap(context, idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Thẻ của tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_2_outlined),
            selectedIcon: Icon(Icons.qr_code_2),
            label: 'Chia sẻ',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Danh bạ',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}
