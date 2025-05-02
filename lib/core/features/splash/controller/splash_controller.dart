import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';

class SplashController {
  static void navigateToOnboardingView() {
    Get.toNamed(AppRoutes.onBoardingView);
  }
}
