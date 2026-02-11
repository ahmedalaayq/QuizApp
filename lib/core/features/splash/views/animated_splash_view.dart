import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AnimatedSplashView extends StatefulWidget {
  const AnimatedSplashView({super.key});

  @override
  State<AnimatedSplashView> createState() => _AnimatedSplashViewState();
}

class _AnimatedSplashViewState extends State<AnimatedSplashView>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  bool _disposed = false;
  String _currentStatus = 'جاري التحميل...';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo Animation Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text Animation Controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Progress Animation Controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo Animation
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Text Animation
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
  }

  void _startAnimationSequence() async {
    try {
      // Start logo animation
      await Future.delayed(const Duration(milliseconds: 300));
      if (!_disposed && mounted) {
        await _logoController.forward();
      }

      // Start text animation
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_disposed && mounted) {
        await _textController.forward();
      }

      // Start initialization process with progress updates
      await _initializeApp();

      // Navigate after animations complete
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_disposed && mounted) {
        _navigateToNextScreen();
      }
    } catch (e, stackTrace) {
      LoggerService.error('Splash animation sequence error', e, stackTrace);
      if (!_disposed && mounted) {
        _navigateToNextScreen();
      }
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize Hive (Local Database)
      _updateStatus('تهيئة قاعدة البيانات المحلية...', 0.2);
      await Future.delayed(const Duration(milliseconds: 500));

      if (!HiveService.isInitialized) {
        await HiveService.init();
      }

      // Step 2: Initialize Firebase
      _updateStatus('الاتصال بالخدمات السحابية...', 0.4);
      await Future.delayed(const Duration(milliseconds: 500));

      await FirebaseService.init();

      // Step 3: Check Authentication
      _updateStatus('التحقق من حالة تسجيل الدخول...', 0.6);
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize auth service if not already done
      if (!Get.isRegistered<AuthService>()) {
        Get.put(AuthService());
      }

      // Step 4: Load User Preferences
      _updateStatus('تحميل الإعدادات...', 0.8);
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Complete
      _updateStatus('اكتمل التحميل', 1.0);
      await Future.delayed(const Duration(milliseconds: 300));

      LoggerService.info('App initialization completed successfully');
    } catch (e, stackTrace) {
      LoggerService.error('App initialization error', e, stackTrace);
      _updateStatus('حدث خطأ في التحميل', 1.0);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  void _updateStatus(String status, double progress) {
    if (!_disposed && mounted) {
      setState(() {
        _currentStatus = status;
      });

      // Update progress animation
      _progressController.animateTo(progress);
    }
  }

  void _navigateToNextScreen() {
    if (_disposed || !mounted) return;

    try {
      final authService = Get.find<AuthService>();

      if (authService.currentUser.value != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed(AppRoutes.loginView);
      }
    } catch (e) {
      // Fallback navigation
      Get.offAllNamed(AppRoutes.loginView);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_logoController.isAnimating) _logoController.stop();
    if (_textController.isAnimating) _textController.stop();
    if (_progressController.isAnimating) _progressController.stop();

    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                    : [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.8),
                      AppColors.secondaryColor,
                    ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo
              AnimatedBuilder(
                animation: _logoScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: AppColors.primaryColor,
                        size: 60.r,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40.h),

              // Animated App Name
              AnimatedBuilder(
                animation: _textFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          'منصة التقييم النفسي',
                          style: AppTextStyles.cairo28w700.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'تقييم شامل ودقيق للحالة النفسية',
                          style: AppTextStyles.cairo16w700.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),

              // Animated Progress Bar with Status
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: Column(
                  children: [
                    // Status Text
                    AnimatedBuilder(
                      animation: _textFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Text(
                            _currentStatus,
                            style: AppTextStyles.cairo14w600.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Progress Bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Container(
                          width: double.infinity,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Progress Percentage
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Text(
                          '${(_progressController.value * 100).toInt()}%',
                          style: AppTextStyles.cairo12w600.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),

              // Loading Dots Animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final progress = (_progressController.value - delay)
                          .clamp(0.0, 1.0);
                      final scale = 0.5 + (0.5 * progress);

                      return Container(
                        width: 8.w * scale,
                        height: 8.w * scale,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: progress),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
