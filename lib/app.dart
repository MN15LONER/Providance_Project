import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';

class MuniReportProApp extends ConsumerStatefulWidget {
  const MuniReportProApp({super.key});

  @override
  ConsumerState<MuniReportProApp> createState() => _MuniReportProAppState();
}

class _MuniReportProAppState extends ConsumerState<MuniReportProApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Muni-Report Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      // Add navigator key for notification navigation
      builder: (context, child) {
        // Store navigator key for notification service
        return Navigator(
          key: NotificationService.navigatorKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => child!,
          ),
        );
      },
    );
  }
}
