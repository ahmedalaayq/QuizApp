import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/animation_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_radio_tile.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();

  // Focus nodes for proper navigation
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _ageFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _occupationFocus = FocusNode();

  final _selectedGender = 'ذكر'.obs;
  final _selectedRole = 'student'.obs;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _ageFocus.dispose();
    _phoneFocus.dispose();
    _occupationFocus.dispose();

    super.dispose();
  }

  Future<void> _performRegistration() async {
    final authService = Get.find<AuthService>();

    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _ageController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى ملء الحقول المطلوبة (*)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور غير متطابقة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 10 || age > 100) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال عمر صحيح (10-100)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      age: age,
      gender: _selectedGender.value,
      phone:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      occupation:
          _occupationController.text.trim().isEmpty
              ? null
              : _occupationController.text.trim(),
      role: _selectedRole.value,
    );
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'إنشاء حساب جديد',
          style: AppTextStyles.cairo18w700.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // Header with Animation
                AnimationService.slideInFromTop(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أدخل بياناتك الشخصية',
                        style: AppTextStyles.cairo20w700.copyWith(
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'سيتم استخدام هذه البيانات لتخصيص تجربتك وحفظ نتائجك',
                        style: AppTextStyles.cairo14w400.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  delay: const Duration(milliseconds: 200),
                ),

                SizedBox(height: 32.h),

                // Name Field with Animation
                AnimationService.slideInFromLeft(
                  AnimatedTextField(
                    label: 'الاسم الكامل *',
                    hint: 'أدخل اسمك الكامل',
                    controller: _nameController,
                    focusNode: _nameFocus,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.person,
                    autofillHints: const [AutofillHints.name],
                    onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      if (value.length < 2) {
                        return 'الاسم يجب أن يكون حرفين على الأقل';
                      }
                      return null;
                    },
                  ),
                  delay: const Duration(milliseconds: 300),
                ),

                SizedBox(height: 16.h),

                // Email Field with Animation
                AnimationService.slideInFromRight(
                  AnimatedTextField(
                    label: 'البريد الإلكتروني *',
                    hint: 'أدخل بريدك الإلكتروني',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email,
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
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

                SizedBox(height: 16.h),

                // Password Field with Animation
                AnimationService.slideInFromLeft(
                  AnimatedTextField(
                    label: 'كلمة المرور *',
                    hint: 'أدخل كلمة المرور (6 أحرف على الأقل)',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock,
                    autofillHints: const [AutofillHints.newPassword],
                    showPasswordStrength: true,
                    onFieldSubmitted:
                        (_) => _confirmPasswordFocus.requestFocus(),
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

                // Confirm Password Field with Animation
                AnimationService.slideInFromRight(
                  AnimatedTextField(
                    label: 'تأكيد كلمة المرور *',
                    hint: 'أعد إدخال كلمة المرور',
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock_outline,
                    autofillHints: const [AutofillHints.newPassword],
                    onFieldSubmitted: (_) => _ageFocus.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  delay: const Duration(milliseconds: 600),
                ),

                SizedBox(height: 16.h),

                // Age Field with Animation
                AnimationService.slideInFromLeft(
                  AnimatedTextField(
                    label: 'العمر *',
                    hint: 'أدخل عمرك',
                    controller: _ageController,
                    focusNode: _ageFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.cake,
                    onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال العمر';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 10 || age > 100) {
                        return 'يرجى إدخال عمر صحيح (10-100)';
                      }
                      return null;
                    },
                  ),
                  delay: const Duration(milliseconds: 700),
                ),

                SizedBox(height: 24.h),

                // Gender Selection with Animation
                AnimationService.fadeIn(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الجنس *',
                        style: AppTextStyles.cairo14w600.copyWith(
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: CustomRadioTile<String>(
                                title: 'ذكر',
                                value: 'ذكر',
                                groupValue: _selectedGender.value,
                                onChanged:
                                    (value) => _selectedGender.value = value!,
                                activeColor: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: CustomRadioTile<String>(
                                title: 'أنثى',
                                value: 'أنثى',
                                groupValue: _selectedGender.value,
                                onChanged:
                                    (value) => _selectedGender.value = value!,
                                activeColor: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  delay: const Duration(milliseconds: 800),
                ),

                SizedBox(height: 24.h),

                // Role Selection with Animation
                AnimationService.slideInFromBottom(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع الحساب *',
                        style: AppTextStyles.cairo14w600.copyWith(
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Obx(
                        () => Column(
                          children: [
                            CustomRadioTile<String>(
                              title: 'طالب/مستخدم عادي',
                              subtitle: 'للاستخدام الشخصي وإجراء التقييمات',
                              value: 'student',
                              groupValue: _selectedRole.value,
                              onChanged:
                                  (value) => _selectedRole.value = value!,
                              activeColor: AppColors.primaryColor,
                            ),
                            SizedBox(height: 12.h),
                            CustomRadioTile<String>(
                              title: 'معالج نفسي',
                              subtitle: 'لإدارة المرضى وعرض التقارير المفصلة',
                              value: 'therapist',
                              groupValue: _selectedRole.value,
                              onChanged:
                                  (value) => _selectedRole.value = value!,
                              activeColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  delay: const Duration(milliseconds: 900),
                ),

                SizedBox(height: 24.h),

                // Phone Field with Animation
                AnimationService.slideInFromLeft(
                  AnimatedTextField(
                    label: 'رقم الهاتف',
                    hint: 'أدخل رقم هاتفك (اختياري)',
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    onFieldSubmitted: (_) => _occupationFocus.requestFocus(),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length < 10) {
                        return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                      }
                      return null;
                    },
                  ),
                  delay: const Duration(milliseconds: 1000),
                ),

                SizedBox(height: 16.h),

                // Occupation Field with Animation
                AnimationService.slideInFromRight(
                  AnimatedTextField(
                    label: 'المهنة/التخصص',
                    hint: 'أدخل مهنتك أو تخصصك (اختياري)',
                    controller: _occupationController,
                    focusNode: _occupationFocus,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.work,
                    autofillHints: const [AutofillHints.jobTitle],
                    onFieldSubmitted: (_) {
                      if (_formKey.currentState!.validate()) {
                        _performRegistration();
                      }
                    },
                  ),
                  delay: const Duration(milliseconds: 1100),
                ),

                SizedBox(height: 32.h),

                // Register Button with Animation
                AnimationService.scaleIn(
                  Obx(
                    () => AnimatedButton(
                      text: 'إنشاء الحساب',
                      icon: Icons.person_add,
                      isLoading: authService.isLoading.value,
                      onPressed:
                          connectivityService.isConnected.value
                              ? () async {
                                if (_formKey.currentState!.validate()) {
                                  await _performRegistration();
                                }
                              }
                              : null,
                    ),
                  ),
                  delay: const Duration(milliseconds: 1200),
                ),

                SizedBox(height: 24.h),

                // Login Link with Animation
                AnimationService.fadeIn(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: AppTextStyles.cairo14w400.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          'تسجيل الدخول',
                          style: AppTextStyles.cairo14w600.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  delay: const Duration(milliseconds: 1300),
                ),

                SizedBox(height: 32.h),

                // Offline Mode Notice with Animation
                Obx(
                  () =>
                      !connectivityService.isConnected.value
                          ? AnimationService.fadeInUp(
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      isDarkMode
                                          ? [
                                            const Color(0xFF2D3748),
                                            const Color(0xFF1A202C),
                                          ]
                                          : [Colors.white, Colors.grey.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? const Color(0xFF4A5568)
                                          : Colors.grey.withValues(alpha: 0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        isDarkMode
                                            ? Colors.black.withValues(
                                              alpha: 0.3,
                                            )
                                            : Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  PulsingWidget(
                                    child: Icon(
                                      Icons.cloud_off,
                                      size: 48.r,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'وضع عدم الاتصال',
                                    style: AppTextStyles.cairo16w700.copyWith(
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : AppColors.primaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'يتطلب إنشاء الحساب اتصالاً بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
                                    style: AppTextStyles.cairo14w400.copyWith(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            delay: const Duration(milliseconds: 1400),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
