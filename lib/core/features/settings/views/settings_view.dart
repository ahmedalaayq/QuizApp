import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/settings/controller/settings_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/theme/theme_controller.dart';
import 'package:quiz_app/core/widgets/custom_radio_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
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
          'الإعدادات',
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
            _buildSectionTitle('المظهر'),
            _buildSettingCard(
              icon: Icons.dark_mode,
              title: 'المظهر',
              subtitle: 'تغيير مظهر التطبيق',
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
            SizedBox(height: 24.h),
            _buildSectionTitle('الإشعارات'),
            _buildSettingCard(
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'تفعيل التنبيهات والتذكيرات',
              trailing: Obx(
                () => Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
                  activeThumbColor: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () =>
                  controller.notificationsEnabled.value
                      ? _buildSettingCard(
                        icon: Icons.schedule,
                        title: 'تكرار التذكير',
                        subtitle:
                            'كل ${controller.reminderFrequency.value} أيام',
                        onTap: () => _showReminderDialog(context, controller),
                      )
                      : const SizedBox.shrink(),
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('الأمان'),
            _buildSettingCard(
              icon: Icons.lock,
              title: 'قفل التطبيق',
              subtitle: 'حماية بيانات بالبصمة أو الرمز',
              trailing: Obx(
                () => Switch(
                  value: controller.biometricEnabled.value,
                  onChanged: controller.toggleBiometric,
                  activeThumbColor: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('البيانات'),
            _buildSettingCard(
              icon: Icons.backup,
              title: 'نسخ احتياطي',
              subtitle: 'حفظ البيانات',
              onTap: () => controller.backupData(),
            ),
            SizedBox(height: 12.h),
            _buildSettingCard(
              icon: Icons.delete_forever,
              title: 'مسح جميع البيانات',
              subtitle: 'حذف جميع الاختبارات والإعدادات',
              onTap: () => _showDeleteDialog(context, controller),
              isDestructive: true,
            ),
            SizedBox(height: 24.h),
            _buildSectionTitle('حول التطبيق'),
            _buildSettingCard(
              icon: Icons.info,
              title: 'عن التطبيق',
              subtitle: 'الإصدار 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
            SizedBox(height: 12.h),
            _buildSettingCard(
              icon: Icons.privacy_tip,
              title: 'سياسة الخصوصية',
              subtitle: 'اطلع على سياسة الخصوصية',
              onTap: () {},
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
    bool isDestructive = false,
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
                color: (isDestructive ? Colors.red : AppColors.primaryColor)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primaryColor,
                size: 24.r,
              ),
            ),
            title: Text(
              title,
              style: AppTextStyles.cairo14w600.copyWith(
                color:
                    isDestructive
                        ? Colors.red
                        : (isDarkMode ? Colors.white : null),
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

  void _showReminderDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('تكرار التذكير', style: AppTextStyles.cairo18w700),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [3, 7, 14, 30].map((days) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: CustomRadioTile<int>(
                    title: 'كل $days أيام',
                    value: days,
                    groupValue: controller.reminderFrequency.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setReminderFrequency(value);
                        Get.back();
                      }
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('تأكيد الحذف', style: AppTextStyles.cairo18w700),
        content: Text(
          'هل أنت متأكد من حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: AppTextStyles.cairo14w400,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: AppTextStyles.cairo14w600),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllData();
              Get.back();
            },
            child: Text(
              'حذف',
              style: AppTextStyles.cairo14w600.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
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
            Text('منصة التقييم النفسي', style: AppTextStyles.cairo16w700),
            SizedBox(height: 8.h),
            Text('الإصدار: 1.0.0', style: AppTextStyles.cairo14w400),
            SizedBox(height: 16.h),
            Text(
              'تطبيق متخصص لتقييم الحالات النفسية والعصبية باستخدام مقاييس نفسية معترف بها دولياً.',
              style: AppTextStyles.cairo13w400,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('حسناً', style: AppTextStyles.cairo14w600),
          ),
        ],
      ),
    );
  }
}
