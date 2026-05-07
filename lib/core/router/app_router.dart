import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/events/screens/home_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/events/screens/create_event_screen.dart';
import '../../features/attendance/screens/attendance_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/event/:id',
        builder: (_, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/create-event', builder: (_, __) => const CreateEventScreen()),
      GoRoute(
        path: '/edit-event/:id',
        builder: (_, state) => CreateEventScreen(eventId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/attendance/:eventId',
        builder: (_, state) => AttendanceScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
