import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToHome();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.whiteColor.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.whiteColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text('🧠', style: TextStyle(fontSize: 70.r)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'منصة التقييم النفسي',
                style: AppTextStyles.cairo24w700.copyWith(
                  color: AppColors.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'تقييم صحتك النفسية والعصبية بثقة',
                style: AppTextStyles.cairo14w400.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 60.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 60.r,
                child: LinearProgressIndicator(
                  minHeight: 3.h,
                  backgroundColor: AppColors.whiteColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.whiteColor.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
