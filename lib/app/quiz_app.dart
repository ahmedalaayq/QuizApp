import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/maintenance/views/maintenance_view.dart';
import 'package:quiz_app/core/features/student/controller/student_controller.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/router/router_manager.dart';
import 'package:quiz_app/core/services/maintenance_service.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/theme_controller.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize maintenance service
    final maintenanceService = Get.put(MaintenanceService());

    return Obx(() {
      // Check maintenance mode with real-time updates
      if (maintenanceService.isMaintenanceMode.value) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const MaintenanceView(),
        );
      }

      return ScreenUtilInit(
        builder: (context, child) {
          // Initialize controllers
          Get.put(StudentController());
          final themeController = Get.put(ThemeController());
          final authService = Get.find<AuthService>();
          final connectivityService = Get.find<ConnectivityService>();

          return Obx(
            () => GetMaterialApp(
              initialRoute: _getInitialRoute(authService, connectivityService),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode.value,
              routes: RouterManager.mainAppRoutes,
              locale: const Locale('ar', 'SA'),
              fallbackLocale: const Locale('ar', 'SA'),
              onReady: () {
                // Navigate based on auth state after app is ready
                Future.delayed(const Duration(milliseconds: 100), () {
                  authService.navigateBasedOnAuthState();
                });
              },
            ),
          );
        },
        designSize: const Size(414, 896),
      );
    });
  }

  String _getInitialRoute(
    AuthService authService,
    ConnectivityService connectivityService,
  ) {
    // Start with animated splash screen
    return AppRoutes.splashView;
  }
}
