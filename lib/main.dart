import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/app/quiz_app.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/services/notification_service.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/app_lock_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/widgets/error_widgets.dart';
import 'package:get/get.dart';

void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggerService.error('Flutter Error', details.exception, details.stack);
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.error('Platform Error', error, stack);
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  bool initializationSuccessful = false;
  String? initializationError;

  try {
    // Initialize Firebase first
    await FirebaseService.init();
    log('Firebase initialized successfully');

    await HiveService.init();
    log('Hive initialized successfully');

    await NotificationService.init();
    log('Notifications initialized successfully');

    Get.put(ConnectivityService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(AppLockService(), permanent: true);

    log('All services initialized successfully');
    initializationSuccessful = true;
  } catch (e, stackTrace) {
    log('Error during initialization: $e');
    LoggerService.error('Initialization Error', e, stackTrace);
    initializationError = e.toString();
  }

  // Run app with error handling
  runApp(
    initializationSuccessful
        ? const QuizApp()
        : _InitializationErrorApp(
          error: initializationError ?? 'Unknown error',
        ),
  );
}

class _InitializationErrorApp extends StatelessWidget {
  final String error;

  const _InitializationErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ErrorScreen(
        title: 'فشل في تشغيل التطبيق',
        message: 'حدث خطأ أثناء تهيئة التطبيق:\n$error',
        actionText: 'إعادة المحاولة',
        onAction: () {
          // Restart the app
          SystemNavigator.pop();
        },
        icon: Icons.warning_amber_rounded,
      ),
      builder: (context, widget) {
        // Set global error widget builder
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'حدث خطأ في التطبيق',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'خطأ: ${errorDetails.exception}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => SystemNavigator.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('إغلاق التطبيق'),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return widget ?? const SizedBox.shrink();
      },
    );
  }
}
