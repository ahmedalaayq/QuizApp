import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_radio_tile.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

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
                // Connection Status
                Obx(
                  () =>
                      !connectivityService.isConnected.value
                          ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            margin: EdgeInsets.only(bottom: 20.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  color: Colors.red,
                                  size: 20.r,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'لا يوجد اتصال بالإنترنت - يرجى التحقق من الاتصال',
                                    style: AppTextStyles.cairo12w500.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                ),

                Text(
                  'أدخل بياناتك الشخصية',
                  style: AppTextStyles.cairo20w700.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'سيتم استخدام هذه البيانات لتخصيص تجربتك وحفظ نتائجك',
                  style: AppTextStyles.cairo14w400.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),

                SizedBox(height: 32.h),

                CustomTextField(
                  label: 'الاسم الكامل *',
                  hint: 'أدخل اسمك الكامل',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                ),

                SizedBox(height: 16.h),

                CustomTextField(
                  label: 'البريد الإلكتروني *',
                  hint: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                ),

                SizedBox(height: 16.h),

                CustomTextField(
                  label: 'كلمة المرور *',
                  hint: 'أدخل كلمة المرور (6 أحرف على الأقل)',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),

                SizedBox(height: 16.h),

                CustomTextField(
                  label: 'تأكيد كلمة المرور *',
                  hint: 'أعد إدخال كلمة المرور',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),

                SizedBox(height: 16.h),

                CustomTextField(
                  label: 'العمر *',
                  hint: 'أدخل عمرك',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.cake,
                ),

                SizedBox(height: 16.h),

                // Gender Selection
                Text(
                  'الجنس *',
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 8.h),

                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: CustomRadioTile<String>(
                          title: 'ذكر',
                          value: 'ذكر',
                          groupValue: _selectedGender.value,
                          onChanged: (value) => _selectedGender.value = value!,
                          activeColor: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomRadioTile<String>(
                          title: 'أنثى',
                          value: 'أنثى',
                          groupValue: _selectedGender.value,
                          onChanged: (value) => _selectedGender.value = value!,
                          activeColor: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Role Selection
                Text(
                  'نوع الحساب *',
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 8.h),

                Obx(
                  () => Column(
                    children: [
                      CustomRadioTile<String>(
                        title: 'طالب/مستخدم عادي',
                        subtitle: 'للاستخدام الشخصي وإجراء التقييمات',
                        value: 'student',
                        groupValue: _selectedRole.value,
                        onChanged: (value) => _selectedRole.value = value!,
                        activeColor: AppColors.primaryColor,
                      ),
                      SizedBox(height: 8.h),
                      CustomRadioTile<String>(
                        title: 'معالج نفسي',
                        subtitle: 'لإدارة المرضى وعرض التقارير المفصلة',
                        value: 'therapist',
                        groupValue: _selectedRole.value,
                        onChanged: (value) => _selectedRole.value = value!,
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                CustomTextField(
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم هاتفك (اختياري)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                ),

                SizedBox(height: 16.h),

                CustomTextField(
                  label: 'المهنة/التخصص',
                  hint: 'أدخل مهنتك أو تخصصك (اختياري)',
                  controller: _occupationController,
                  prefixIcon: Icons.work,
                ),

                SizedBox(height: 32.h),

                Obx(
                  () => CustomElevatedButton(
                    label: 'إنشاء الحساب',
                    onPressed:
                        connectivityService.isConnected.value
                            ? () async {
                              // Validation
                              if (_nameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty ||
                                  _confirmPasswordController.text.isEmpty ||
                                  _ageController.text.isEmpty) {
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                Get.snackbar(
                                  'خطأ',
                                  'يرجى ملء الحقول المطلوبة (*)',
                                  backgroundColor:
                                      isDarkMode
                                          ? const Color(0xFF21262D)
                                          : Colors.red,
                                  colorText:
                                      isDarkMode
                                          ? const Color(0xFFF0F6FC)
                                          : Colors.white,
                                );
                                return;
                              }

                              if (_passwordController.text !=
                                  _confirmPasswordController.text) {
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                Get.snackbar(
                                  'خطأ',
                                  'كلمة المرور غير متطابقة',
                                  backgroundColor:
                                      isDarkMode
                                          ? const Color(0xFF21262D)
                                          : Colors.red,
                                  colorText:
                                      isDarkMode
                                          ? const Color(0xFFF0F6FC)
                                          : Colors.white,
                                );
                                return;
                              }

                              if (_passwordController.text.length < 6) {
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                Get.snackbar(
                                  'خطأ',
                                  'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                                  backgroundColor:
                                      isDarkMode
                                          ? const Color(0xFF21262D)
                                          : Colors.red,
                                  colorText:
                                      isDarkMode
                                          ? const Color(0xFFF0F6FC)
                                          : Colors.white,
                                );
                                return;
                              }

                              final age = int.tryParse(_ageController.text);
                              if (age == null || age < 10 || age > 100) {
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                Get.snackbar(
                                  'خطأ',
                                  'يرجى إدخال عمر صحيح (10-100)',
                                  backgroundColor:
                                      isDarkMode
                                          ? const Color(0xFF21262D)
                                          : Colors.red,
                                  colorText:
                                      isDarkMode
                                          ? const Color(0xFFF0F6FC)
                                          : Colors.white,
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
                            : null,
                    isLoading: authService.isLoading.value,
                  ),
                ),

                SizedBox(height: 24.h),

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

                SizedBox(height: 32.h),

                // Offline Mode Notice
                Obx(
                  () =>
                      !connectivityService.isConnected.value
                          ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? Theme.of(context).cardColor
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 48.r,
                                  color: Colors.grey,
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
