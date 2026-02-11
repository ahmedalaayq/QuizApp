import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/theme/theme_controller.dart';
import 'package:quiz_app/core/services/animation_service.dart';

class GuestSettingsView extends StatelessWidget {
  const GuestSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        title: Text(
          'إعدادات التطبيق',
          style: AppTextStyles.cairo20w700.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            AnimationService.slideInFromTop(
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.1),
                      AppColors.primaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor,
                      size: 24.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'يمكنك الوصول للإعدادات الأساسية حتى بدون تسجيل الدخول',
                        style: AppTextStyles.cairo14w500.copyWith(
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Theme Section
            AnimationService.slideInFromLeft(
              _buildSectionTitle('المظهر'),
              delay: const Duration(milliseconds: 200),
            ),

            AnimationService.slideInFromRight(
              _buildSettingCard(
                icon: Icons.dark_mode,
                title: 'المظهر الداكن',
                subtitle: 'تغيير مظهر التطبيق بين الفاتح والداكن',
                trailing: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? const Color(0xFF21262D)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Switch(
                      value: themeController.isCurrentlyDark,
                      onChanged: (value) => themeController.setTheme(value),
                      activeThumbColor: AppColors.primaryColor,
                      activeTrackColor: AppColors.primaryColor.withValues(
                        alpha: 0.3,
                      ),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              delay: const Duration(milliseconds: 300),
            ),

            SizedBox(height: 24.h),

            // About Section
            AnimationService.slideInFromLeft(
              _buildSectionTitle('حول التطبيق'),
              delay: const Duration(milliseconds: 400),
            ),

            AnimationService.slideInFromRight(
              _buildSettingCard(
                icon: Icons.info,
                title: 'عن التطبيق',
                subtitle: 'معلومات حول منصة التقييم النفسي',
                onTap: () => _showAboutDialog(context),
              ),
              delay: const Duration(milliseconds: 500),
            ),

            SizedBox(height: 12.h),

            AnimationService.slideInFromLeft(
              _buildSettingCard(
                icon: Icons.privacy_tip,
                title: 'سياسة الخصوصية',
                subtitle: 'اطلع على سياسة الخصوصية وحماية البيانات',
                onTap: () => _showPrivacyDialog(context),
              ),
              delay: const Duration(milliseconds: 600),
            ),

            SizedBox(height: 12.h),

            AnimationService.slideInFromRight(
              _buildSettingCard(
                icon: Icons.help_outline,
                title: 'المساعدة والدعم',
                subtitle: 'كيفية استخدام التطبيق والحصول على المساعدة',
                onTap: () => _showHelpDialog(context),
              ),
              delay: const Duration(milliseconds: 700),
            ),

            SizedBox(height: 24.h),

            // Login Prompt
            AnimationService.fadeInUp(
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.login, color: Colors.white, size: 32.r),
                    SizedBox(height: 12.h),
                    Text(
                      'للوصول لجميع المميزات',
                      style: AppTextStyles.cairo16w700.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'سجل دخولك للوصول لجميع الإعدادات والمميزات المتقدمة',
                      style: AppTextStyles.cairo13w400.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'العودة لتسجيل الدخول',
                        style: AppTextStyles.cairo14w600,
                      ),
                    ),
                  ],
                ),
              ),
              delay: const Duration(milliseconds: 800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
      child: Text(
        title,
        style: AppTextStyles.cairo16w700.copyWith(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            onTap: onTap,
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24.r),
            ),
            title: Text(
              title,
              style: AppTextStyles.cairo14w600.copyWith(
                color: isDarkMode ? Colors.white : null,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: AppTextStyles.cairo12w400.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            trailing:
                trailing ??
                (onTap != null
                    ? Icon(
                      Icons.arrow_forward_ios,
                      size: 16.r,
                      color: isDarkMode ? Colors.white70 : null,
                    )
                    : null),
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('عن التطبيق', style: AppTextStyles.cairo18w700),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppColors.primaryColor,
                  size: 32.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'منصة التقييم النفسي',
                    style: AppTextStyles.cairo16w700.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text('الإصدار: 1.0.0', style: AppTextStyles.cairo14w600),
            SizedBox(height: 8.h),
            Text(
              'تاريخ الإصدار: فبراير 2026',
              style: AppTextStyles.cairo14w400,
            ),
            SizedBox(height: 16.h),
            Text(
              'تطبيق متخصص لتقييم الحالات النفسية والعصبية باستخدام مقاييس نفسية معترف بها دولياً. يوفر التطبيق أدوات تقييم شاملة للطلاب والمعالجين النفسيين.',
              style: AppTextStyles.cairo13w400,
            ),
            SizedBox(height: 16.h),
            Text(
              'المميزات الرئيسية:',
              style: AppTextStyles.cairo14w600.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            ...[
              'تقييمات نفسية متنوعة',
              'تقارير مفصلة',
              'إحصائيات شاملة',
              'واجهة سهلة الاستخدام',
            ].map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(feature, style: AppTextStyles.cairo12w400),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'حسناً',
              style: AppTextStyles.cairo14w600.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('سياسة الخصوصية', style: AppTextStyles.cairo18w700),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.',
                style: AppTextStyles.cairo14w600.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              _buildPrivacySection(
                'جمع البيانات',
                'نجمع فقط البيانات الضرورية لتشغيل التطبيق وتقديم الخدمة.',
              ),
              _buildPrivacySection(
                'استخدام البيانات',
                'تُستخدم بياناتك لتحسين تجربة الاستخدام وتقديم تقييمات دقيقة.',
              ),
              _buildPrivacySection(
                'حماية البيانات',
                'نستخدم أحدث تقنيات التشفير لحماية بياناتك من الوصول غير المصرح به.',
              ),
              _buildPrivacySection(
                'مشاركة البيانات',
                'لا نشارك بياناتك الشخصية مع أطراف ثالثة دون موافقتك الصريحة.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'فهمت',
              style: AppTextStyles.cairo14w600.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cairo13w600),
          SizedBox(height: 4.h),
          Text(
            content,
            style: AppTextStyles.cairo12w400.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('المساعدة والدعم', style: AppTextStyles.cairo18w700),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                Icons.login,
                'تسجيل الدخول',
                'استخدم بريدك الإلكتروني وكلمة المرور للدخول',
              ),
              _buildHelpSection(
                Icons.assignment,
                'إجراء التقييمات',
                'اختر التقييم المناسب واتبع التعليمات',
              ),
              _buildHelpSection(
                Icons.analytics,
                'عرض النتائج',
                'يمكنك مراجعة نتائجك في قسم الإحصائيات',
              ),
              _buildHelpSection(
                Icons.support_agent,
                'الدعم الفني',
                'للمساعدة تواصل مع فريق الدعم الفني',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'حسناً',
              style: AppTextStyles.cairo14w600.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(IconData icon, String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cairo13w600),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: AppTextStyles.cairo12w400.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
