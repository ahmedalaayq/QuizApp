import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/achievements/views/achievements_view.dart';
import 'package:quiz_app/core/features/admin/views/admin_panel_view.dart';
import 'package:quiz_app/core/features/answer/views/answer_view.dart';
import 'package:quiz_app/core/features/assessment/views/assessment_view.dart';
import 'package:quiz_app/core/features/assessment/views/assessments_list_view.dart';
import 'package:quiz_app/core/features/assessment/views/assessment_result_view.dart';
import 'package:quiz_app/core/features/auth/views/forgot_password_view.dart';
import 'package:quiz_app/core/features/auth/views/login_view.dart';
import 'package:quiz_app/core/features/auth/views/register_view.dart';
import 'package:quiz_app/core/features/home/views/home_view.dart';
import 'package:quiz_app/core/features/maintenance/views/maintenance_view.dart';
import 'package:quiz_app/core/features/offline/views/offline_view.dart';
import 'package:quiz_app/core/features/on_boarding/views/on_boarding_view.dart';
import 'package:quiz_app/core/features/quiz/views/quiz_view.dart';
import 'package:quiz_app/core/features/settings/views/settings_view.dart';
import 'package:quiz_app/core/features/settings/views/guest_settings_view.dart';
import 'package:quiz_app/core/features/splash/views/animated_splash_view.dart';
import 'package:quiz_app/core/features/statistics/views/statistics_view.dart';
import 'package:quiz_app/core/features/student/controller/student_controller.dart';
import 'package:quiz_app/core/features/student/views/student_rating_view.dart';
import 'package:quiz_app/core/router/app_routes.dart';

class RouterManager {
  static final Map<String, WidgetBuilder> mainAppRoutes = {
    AppRoutes.splashView: (context) => const AnimatedSplashView(),
    AppRoutes.maintenanceView: (context) => const MaintenanceView(),
    // AppRoutes.splashView: (context) => const SplashView(),
    AppRoutes.onBoardingView: (context) => const OnBoardingView(),
    AppRoutes.loginView: (context) => const LoginView(),
    '/register': (context) => const RegisterView(),
    '/offline': (context) => const OfflineView(),
    AppRoutes.forgetPasswordView: (context) => const ForgotPasswordView(),
    AppRoutes.quizView: (context) => const QuizView(),
    AppRoutes.answerView: (context) => const AnswerView(),
    AppRoutes.assessmentsList: (context) => const AssessmentsListView(),
    AppRoutes.assessment: (context) => const AssessmentView(),
    AppRoutes.assessmentResult: (context) => const AssessmentResultView(),
    AppRoutes.home: (context) => const HomeView(),
    AppRoutes.adminPanel: (context) => const AdminPanelView(),
    AppRoutes.statistics: (context) => const StatisticsView(),
    AppRoutes.achievements: (context) => const AchievementsView(),
    AppRoutes.settings: (context) => const SettingsView(),
    AppRoutes.guestSettings: (context) => const GuestSettingsView(),
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
