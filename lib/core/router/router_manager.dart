import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/answer/views/answer_view.dart';
import 'package:quiz_app/core/features/assessment/views/assessment_view.dart';
import 'package:quiz_app/core/features/assessment/views/assessments_list_view.dart';
import 'package:quiz_app/core/features/assessment/views/assessment_result_view.dart';
import 'package:quiz_app/core/features/home/views/home_view.dart';
import 'package:quiz_app/core/features/login/views/login_view.dart';
import 'package:quiz_app/core/features/on_boarding/views/on_boarding_view.dart';
import 'package:quiz_app/core/features/quiz/views/quiz_view.dart';
import 'package:quiz_app/core/features/settings/views/settings_view.dart';
import 'package:quiz_app/core/features/splash/views/splash_view.dart';
import 'package:quiz_app/core/features/statistics/views/statistics_view.dart';
import 'package:quiz_app/core/features/student/controller/student_controller.dart';
import 'package:quiz_app/core/features/student/views/student_rating_view.dart';
import 'package:quiz_app/core/router/app_routes.dart';

class RouterManager {
  static final Map<String, WidgetBuilder> mainAppRoutes = {
    AppRoutes.splashView: (context) => const SplashView(),
    AppRoutes.onBoardingView: (context) => const OnBoardingView(),
    AppRoutes.loginView: (context) => const LoginView(),
    AppRoutes.quizView: (context) => const QuizView(),
    AppRoutes.answerView: (context) => const AnswerView(),
    AppRoutes.assessmentsList: (context) => const AssessmentsListView(),
    AppRoutes.assessment: (context) => const AssessmentView(),
    AppRoutes.assessmentResult: (context) => const AssessmentResultView(),
    AppRoutes.home: (context) => const HomeView(),
    '/statistics': (context) => const StatisticsView(),
    '/settings': (context) => const SettingsView(),
    '/achievements':
        (context) => const Scaffold(
          body: Center(child: Text('صفحة الإنجازات - قيد التطوير')),
        ),
    AppRoutes.studentRating: (context) {
      try {
        final controller = Get.find<StudentController>();
        return StudentRatingView(students: controller.students.toList());
      } catch (e) {
        final controller = Get.put(StudentController());
        return StudentRatingView(students: controller.students.toList());
      }
    },
  };
}
