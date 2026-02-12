import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = Get.find<AuthService>();

  // Focus node for email field
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authService.resetPassword(
        _emailController.text.trim(),
      );
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('استعادة كلمة المرور'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                // Header Icon
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: AppColors.primaryColor,
                      size: 40.r,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  'نسيت كلمة المرور؟',
                  style: AppTextStyles.cairo24w700.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 12.h),

                // Description
                Text(
                  'أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور',
                  style: AppTextStyles.cairo14w400.copyWith(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 40.h),

                // Email Field
                AnimatedTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.email_outlined,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      _resetPassword();
                    }
                  },
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

                SizedBox(height: 32.h),

                // Reset Button
                Obx(
                  () => AnimatedButton(
                    text: 'إرسال رابط الاستعادة',
                    onPressed:
                        _authService.isLoading.value ? null : _resetPassword,
                    isLoading: _authService.isLoading.value,
                    icon: Icons.send,
                  ),
                ),

                SizedBox(height: 24.h),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'العودة لتسجيل الدخول',
                      style: AppTextStyles.cairo14w600.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
