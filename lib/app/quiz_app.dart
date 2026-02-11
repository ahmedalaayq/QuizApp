import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/maintenance/views/maintenance_view.dart';
import 'package:quiz_app/core/features/student/controller/student_controller.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/router/router_manager.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/theme_controller.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    final isMaintenanceMode = FirebaseService.isMaintenanceMode();

    if (isMaintenanceMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MaintenanceView(),
      );
    }

    return ScreenUtilInit(
      builder: (context, child) {
      
        Get.put(StudentController());
        final themeController = Get.put(ThemeController());

        return Obx(
          () => GetMaterialApp(
            initialRoute: AppRoutes.splashView,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            routes: RouterManager.mainAppRoutes,
            locale: const Locale('ar', 'SA'),
            fallbackLocale: const Locale('ar', 'SA'),
          ),
        );
      },
      designSize: const Size(414, 896),
    );
  }
}
