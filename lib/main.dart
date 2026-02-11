import 'package:flutter/material.dart';
import 'package:quiz_app/app/quiz_app.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HiveService.init();
  
  await FirebaseService.init();
  
  await NotificationService.init();
  
  runApp(const QuizApp());
}
