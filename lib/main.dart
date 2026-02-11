import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quiz_app/app/quiz_app.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/services/notification_service.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/app_lock_service.dart';
import 'package:quiz_app/core/services/maintenance_service.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  } catch (e) {
    log('Error during initialization: $e');
  }

  runApp(const QuizApp());
}
