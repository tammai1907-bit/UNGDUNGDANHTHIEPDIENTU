import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../providers/wallet_provider.dart';
import 'auth/login_screen.dart';
import 'home/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppEntry();
  }

  Future<void> _checkAppEntry() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    await authProvider.initAuth();
    await cardProvider.loadMyCards();
    await walletProvider.loadContacts();

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      if (authProvider.isBiometricEnabled && authProvider.canUseBiometrics) {
        final authenticated = await authProvider.loginWithBiometrics();
        if (authenticated && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
          return;
        }
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(
                Icons.badge_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DANH THIẾP ĐIỆN TỬ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Digital Business Card & Contact Wallet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
