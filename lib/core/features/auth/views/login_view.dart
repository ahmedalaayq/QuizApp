import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';
import 'package:quiz_app/core/services/animation_service.dart';
import 'package:quiz_app/core/features/settings/views/guest_settings_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final connectivityService = Get.find<ConnectivityService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings Button
                AnimationService.slideInFromTop(
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Get.to(
                          () => const GuestSettingsView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Theme.of(context).cardColor
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.settings,
                          color: AppColors.primaryColor,
                          size: 24.r,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Animated Logo and Welcome Section
                AnimationService.slideInFromTop(
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 30.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Theme.of(context).cardColor
                              : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimationService.bounceIn(
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 30.r,
                            ),
                          ),
                          delay: const Duration(milliseconds: 300),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedWaveText(
                                style: AppTextStyles.cairo20w700.copyWith(
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : AppColors.primaryDark,
                                ),
                                text: 'مرحباً بك',
                              ),
                              SizedBox(height: 4.h),
                              AnimatedTypewriterText(
                                style: AppTextStyles.cairo14w400.copyWith(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black,
                                ),
                                text:
                                    'سجل دخولك للوصول إلى منصة التقييم النفسي',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  delay: const Duration(milliseconds: 200),
                ),

                SizedBox(height: 40.h),

                // Connection Status with Animation
                Obx(
                  () =>
                      !connectivityService.isConnected.value
                          ? AnimationService.shake(
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              margin: EdgeInsets.only(bottom: 20.h),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  PulsingWidget(
                                    child: Icon(
                                      Icons.wifi_off,
                                      color: Colors.red,
                                      size: 24.r,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      'لا يوجد اتصال بالإنترنت - تحقق من الاتصال',
                                      style: AppTextStyles.cairo14w500.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),

                // Email Field with Animation
                AnimationService.slideInFromLeft(
                  AnimatedTextField(
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل بريدك الإلكتروني',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  delay: const Duration(milliseconds: 400),
                ),

                SizedBox(height: 20.h),

                // Password Field with Animation
                AnimationService.slideInFromRight(
                  AnimatedTextField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  delay: const Duration(milliseconds: 500),
                ),

                SizedBox(height: 16.h),

                // Forgot Password with Animation
                AnimationService.fadeIn(
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.forgetPasswordView);
                      },
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: AppTextStyles.cairo14w600.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  delay: const Duration(milliseconds: 600),
                ),

                SizedBox(height: 30.h),

                // Login Button with Animation
                AnimationService.scaleIn(
                  Obx(
                    () => AnimatedButton(
                      text: 'تسجيل الدخول',
                      isLoading: authService.isLoading.value,
                      icon: Icons.login,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          final success = await authService.signIn(
                            email: email,
                            password: password,
                          );

                          if (success) {
                            Get.offAllNamed('/home');
                          }
                        }
                      },
                    ),
                  ),
                  delay: const Duration(milliseconds: 700),
                ),

                SizedBox(height: 30.h),

                // Register Link with Animation
                AnimationService.slideInFromBottom(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: AppTextStyles.cairo14w400.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed('/register'),
                        child: Text(
                          'إنشاء حساب',
                          style: AppTextStyles.cairo14w600.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  delay: const Duration(milliseconds: 800),
                ),

                SizedBox(height: 40.h),

                // Features Preview with Animation
                AnimationService.fadeInUp(
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Theme.of(context).cardColor
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        PulsingWidget(
                          child: Icon(
                            Icons.security,
                            color: AppColors.primaryColor,
                            size: 40.r,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'منصة آمنة ومحمية',
                          style: AppTextStyles.cairo16w700.copyWith(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'بياناتك محمية بأعلى معايير الأمان والخصوصية',
                          style: AppTextStyles.cairo13w400.copyWith(
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  delay: const Duration(milliseconds: 900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
