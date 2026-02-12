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
import 'package:quiz_app/core/widgets/error_widgets.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (context, child) {
        return _AppWithErrorHandling();
      },
    );
  }
}

class _AppWithErrorHandling extends StatefulWidget {
  @override
  State<_AppWithErrorHandling> createState() => _AppWithErrorHandlingState();
}

class _AppWithErrorHandlingState extends State<_AppWithErrorHandling> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize maintenance service with error handling
      if (!Get.isRegistered<MaintenanceService>()) {
        Get.put(MaintenanceService());
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error initializing app services', e, stackTrace);
      setState(() {
        _hasError = true;
        _errorMessage = 'فشل في تهيئة التطبيق: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Global error handling
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          title: 'خطأ في التطبيق',
          message: _errorMessage,
          actionText: 'إعادة المحاولة',
          onAction: () {
            setState(() {
              _hasError = false;
              _errorMessage = '';
            });
            _initializeApp();
          },
        ),
      );
    }

    return _buildMainApp();
  }

  Widget _buildMainApp() {
    try {
      final maintenanceService = Get.find<MaintenanceService>();

      return Obx(() {
        // Check maintenance mode with error handling
        try {
          if (maintenanceService.isMaintenanceMode.value) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const MaintenanceView(),
              // Add error widget builder for maintenance mode
              builder: (context, widget) {
                ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                  return _buildCustomErrorWidget(errorDetails);
                };
                return widget ?? const SizedBox.shrink();
              },
            );
          }
        } catch (e, stackTrace) {
          LoggerService.error('Error checking maintenance mode', e, stackTrace);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ErrorScreen(
              title: 'خطأ في النظام',
              message: 'فشل في التحقق من حالة الصيانة',
              actionText: 'إعادة المحاولة',
              onAction: () => _initializeApp(),
            ),
          );
        }

        return _buildMainMaterialApp();
      });
    } catch (e, stackTrace) {
      LoggerService.error('Error building main app', e, stackTrace);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          title: 'خطأ في التطبيق',
          message: 'حدث خطأ غير متوقع في التطبيق',
          actionText: 'إعادة تشغيل',
          onAction: () => _initializeApp(),
        ),
      );
    }
  }

  Widget _buildMainMaterialApp() {
    try {
      // Initialize controllers with error handling
      if (!Get.isRegistered<StudentController>()) {
        Get.put(StudentController());
      }

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

          // Global error widget builder
          builder: (context, widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return _buildCustomErrorWidget(errorDetails);
            };
            return widget ?? const SizedBox.shrink();
          },

          // Handle route errors
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder:
                  (context) => ErrorScreen(
                    title: 'صفحة غير موجودة',
                    message: 'الصفحة المطلوبة غير متوفرة',
                    actionText: 'العودة للرئيسية',
                    onAction: () => Get.offAllNamed(AppRoutes.home),
                  ),
            );
          },

          onReady: () {
            try {
              // Navigate based on auth state after app is ready
              Future.delayed(const Duration(milliseconds: 100), () {
                authService.navigateBasedOnAuthState();
              });
            } catch (e, stackTrace) {
              LoggerService.error('Error in onReady callback', e, stackTrace);
            }
          },
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error building main material app', e, stackTrace);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          title: 'خطأ في التطبيق',
          message: 'فشل في تحميل التطبيق الرئيسي',
          actionText: 'إعادة المحاولة',
          onAction: () => _initializeApp(),
        ),
      );
    }
  }

  Widget _buildCustomErrorWidget(FlutterErrorDetails errorDetails) {
    LoggerService.error(
      'Flutter Error Widget',
      errorDetails.exception,
      errorDetails.stack,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 80.r),
              SizedBox(height: 24.h),
              Text(
                'حدث خطأ في التطبيق',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'نعتذر عن هذا الخطأ. يرجى إعادة تشغيل التطبيق.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  // Try to navigate to home or restart
                  try {
                    Get.offAllNamed(AppRoutes.splashView);
                  } catch (e) {
                    // If navigation fails, show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى إعادة تشغيل التطبيق يدوياً'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitialRoute(
    AuthService authService,
    ConnectivityService connectivityService,
  ) {
    try {
      // Start with animated splash screen
      return AppRoutes.splashView;
    } catch (e) {
      LoggerService.error('Error getting initial route', e);
      return AppRoutes.splashView; // Fallback
    }
  }
}
