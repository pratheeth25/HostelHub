import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final user = ref.read(authStateProvider).valueOrNull;
      context.go(user != null ? '/home' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub_rounded, size: 80, color: cs.onPrimary)
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              'CampusSphere',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Your Campus, Your Community',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onPrimary.withOpacity(0.8)),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
