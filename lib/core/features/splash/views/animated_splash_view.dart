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
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
  }

  void _startAnimationSequence() async {
    final splashStartTime = DateTime.now();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) await _logoController.forward();

      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) await _textController.forward();

      // يبدأ البروجريس يتحرك تدريجياً
      _progressController.forward();

      await _initializeApp();

      // ضمان مدة لا تقل عن 3 ثواني
      final elapsed = DateTime.now().difference(splashStartTime);
      const minDuration = Duration(seconds: 3);

      if (elapsed < minDuration) {
        await Future.delayed(minDuration - elapsed);
      }

      if (mounted) _navigateToNextScreen();
    } catch (e, stackTrace) {
      LoggerService.error('Splash sequence error', e, stackTrace);
      if (mounted) _navigateToNextScreen();
    }
  }

  Future<void> _initializeApp() async {
    try {
      _updateStatus('تهيئة قاعدة البيانات...', 0.2);
      await HiveService.init();

      _updateStatus('الاتصال بالخدمات السحابية...', 0.5);
      await FirebaseService.init();

      _updateStatus('التحقق من تسجيل الدخول...', 0.7);

      if (!Get.isRegistered<AuthService>()) {
        Get.put(AuthService());
      }

      _updateStatus('تحميل الإعدادات...', 0.9);

      await Future.delayed(const Duration(milliseconds: 400));

      _updateStatus('اكتمل التحميل', 1.0);

      LoggerService.info('Initialization completed');
    } catch (e, stackTrace) {
      LoggerService.error('Initialization error', e, stackTrace);
      _updateStatus('حدث خطأ أثناء التحميل', 1.0);
    }
  }

  void _updateStatus(String status, double progress) {
    if (!mounted) return;

    setState(() => _currentStatus = status);

    _progressController.animateTo(
      progress,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    try {
      final authService = Get.find<AuthService>();

      if (authService.currentUser.value != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed(AppRoutes.loginView);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.loginView);
    }
  }

  @override
  void dispose() {
    _disposed = true;
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
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.85),
                    AppColors.secondaryColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              /// Logo
              AnimatedBuilder(
                animation: _logoScaleAnimation,
                builder: (_, __) => Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
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
                ),
              ),

              SizedBox(height: 40.h),

              /// Title
              AnimatedBuilder(
                animation: _textFadeAnimation,
                builder: (_, __) => Opacity(
                  opacity: _textFadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'منصة التقييم النفسي',
                        style: AppTextStyles.cairo28w700
                            .copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'تقييم شامل ودقيق للحالة النفسية',
                        style: AppTextStyles.cairo16w700.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              /// Status + Progress
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: Column(
                  children: [
                    Text(
                      _currentStatus,
                      style: AppTextStyles.cairo14w600.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6.h,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (_, __) => Text(
                        '${(_progressController.value * 100).toInt()}%',
                        style: AppTextStyles.cairo12w600.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }
}
