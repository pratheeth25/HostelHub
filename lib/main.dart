import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'core/theme/app_theme.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';

import 'features/announcements/presentation/providers/announcements_provider.dart';
import 'features/attendance/presentation/providers/attendance_provider.dart';
import 'features/complaints/presentation/providers/complaints_provider.dart';
import 'features/food/presentation/providers/food_provider.dart';

import 'features/auth/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint("Firebase initialized successfully");
  } catch (e, stackTrace) {
    debugPrint("Firebase initialization error: $e");
    debugPrintStack(stackTrace: stackTrace);
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(const HostelHubApp());
}

class HostelHubApp extends StatelessWidget {
  const HostelHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        /// Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        /// Feature Providers
        ChangeNotifierProvider(
          create: (_) => AnnouncementsProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ComplaintsProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => FoodProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Hostel Hub',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}