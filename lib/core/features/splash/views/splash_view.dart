import 'package:flutter/material.dart';
import 'package:quiz_app/core/features/splash/controller/splash_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_button.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Q', style: AppTextStyles.onboardingStyle.copyWith(color: AppColors.whiteColor)),
            CustomButton(
              radiusValue: 35,
              backgroundColor: AppColors.whiteColor,
              foregroundColor: AppColors.secondaryColor,
              onPressed: SplashController.navigateToOnboardingView,
              buttonName: 'Get Started',
              buttonTextStyle: AppTextStyles.montserrat21w500,
            ),
          ],
        ),
      ),
    );
  }
}
