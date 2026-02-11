import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/admin/controller/admin_controller.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AdminSystemSettingsTab extends StatelessWidget {
  final AdminController controller;
  final bool isDarkMode;
  final AuthService authService;

  const AdminSystemSettingsTab({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maintenance Mode Section
          _buildMaintenanceSection(),
          SizedBox(height: 24.h),

          // App Configuration Section
          _buildAppConfigSection(),
          SizedBox(height: 24.h),

          // SuperAdmin Password Section (only for SuperAdmin)
          if (authService.isSuperAdmin) _buildSuperAdminPasswordSection(),
          if (authService.isSuperAdmin) SizedBox(height: 24.h),

          // Data Management Section
          if (authService.isAdmin) _buildDataManagementSection(),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build, color: Colors.orange, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                'وضع الصيانة',
                style: AppTextStyles.cairo18w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'تفعيل وضع الصيانة سيمنع المستخدمين من الوصول للتطبيق',
                  style: AppTextStyles.cairo14w400.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.isMaintenanceMode.value,
                  onChanged: (value) => _showMaintenanceDialog(value),
                  activeThumbColor: Colors.orange,
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.isMaintenanceMode.value) {
              return Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20.r),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            controller.maintenanceMessage.value,
                            style: AppTextStyles.cairo12w500.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSuperAdminPasswordSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.purple, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                'أمان المدير العام',
                style: AppTextStyles.cairo18w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Text(
            'تغيير كلمة مرور المدير العام المستخدمة لتعيين أدوار المستخدمين',
            style: AppTextStyles.cairo14w400.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),

          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'كلمة المرور الافتراضية: engAhmedEmad@A12345',
                    style: AppTextStyles.cairo12w500.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showChangePasswordDialog(),
              icon: const Icon(Icons.lock_reset),
              label: const Text('تغيير كلمة مرور المدير العام'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppConfigSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_applications, color: Colors.blue, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                'إعدادات التطبيق',
                style: AppTextStyles.cairo18w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // App Version
          _buildSettingRow(
            'إصدار التطبيق',
            controller.appVersion.value,
            Icons.info,
            Colors.blue,
            onTap: () => _showVersionDialog(),
          ),

          // Force Update
          _buildSettingToggle(
            'فرض التحديث',
            'إجبار المستخدمين على تحديث التطبيق',
            controller.forceUpdate.value,
            Icons.system_update,
            Colors.red,
            (value) => controller.updateAppSettings(forceUpdateFlag: value),
          ),

          // Premium Features
          _buildSettingToggle(
            'الميزات المميزة',
            'تفعيل الميزات المدفوعة في التطبيق',
            controller.premiumFeaturesEnabled.value,
            Icons.star,
            Colors.amber,
            (value) => controller.updateAppSettings(premiumEnabled: value),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Colors.purple, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                'إدارة البيانات',
                style: AppTextStyles.cairo18w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.exportAllData(),
                  icon: const Icon(Icons.download),
                  label: const Text('تصدير البيانات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBackupDialog(),
                  icon: const Icon(Icons.backup),
                  label: const Text('نسخ احتياطي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.cairo14w500.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.cairo14w600.copyWith(color: color),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Color color,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cairo14w500.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.cairo12w400.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: color),
        ],
      ),
    );
  }

  void _showMaintenanceDialog(bool enable) {
    final messageController = TextEditingController(
      text: controller.maintenanceMessage.value,
    );

    Get.dialog(
      AlertDialog(
        title: Text(enable ? 'تفعيل وضع الصيانة' : 'إلغاء وضع الصيانة'),
        content:
            enable
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('رسالة الصيانة:'),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                )
                : const Text('هل أنت متأكد من إلغاء وضع الصيانة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleMaintenanceMode(
                enable,
                enable ? messageController.text : null,
              );
            },
            child: Text(enable ? 'تفعيل' : 'إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.security, color: Colors.purple),
                SizedBox(width: 8.w),
                const Text('تغيير كلمة مرور المدير العام'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Password
                  TextField(
                    controller: currentPasswordController,
                    obscureText: !showCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الحالية',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () => showCurrentPassword = !showCurrentPassword,
                            ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // New Password
                  TextField(
                    controller: newPasswordController,
                    obscureText: !showNewPassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () => showNewPassword = !showNewPassword,
                            ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      helperText: 'يجب أن تحتوي على 8 أحرف على الأقل',
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Confirm Password
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور الجديدة',
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            () => setState(
                              () => showConfirmPassword = !showConfirmPassword,
                            ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                  if (isLoading) ...[
                    SizedBox(height: 16.h),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Get.back(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          // Validate inputs
                          if (currentPasswordController.text.isEmpty) {
                            Get.snackbar(
                              'خطأ',
                              'يرجى إدخال كلمة المرور الحالية',
                            );
                            return;
                          }

                          if (newPasswordController.text.isEmpty) {
                            Get.snackbar(
                              'خطأ',
                              'يرجى إدخال كلمة المرور الجديدة',
                            );
                            return;
                          }

                          if (newPasswordController.text.length < 8) {
                            Get.snackbar(
                              'خطأ',
                              'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل',
                            );
                            return;
                          }

                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            Get.snackbar(
                              'خطأ',
                              'كلمة المرور الجديدة وتأكيدها غير متطابقين',
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // Import SuperAdminService
                            final success = await controller
                                .changeSuperAdminPassword(
                                  currentPasswordController.text,
                                  newPasswordController.text,
                                );

                            if (success) {
                              Get.back();
                              Get.snackbar(
                                'نجح',
                                'تم تغيير كلمة مرور المدير العام بنجاح',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'خطأ',
                                'كلمة المرور الحالية غير صحيحة',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'خطأ',
                              'حدث خطأ أثناء تغيير كلمة المرور: ${e.toString()}',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تغيير كلمة المرور'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVersionDialog() {
    final versionController = TextEditingController(
      text: controller.appVersion.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('تحديث إصدار التطبيق'),
        content: TextField(
          controller: versionController,
          decoration: InputDecoration(
            labelText: 'رقم الإصدار',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateAppSettings(version: versionController.text);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('نسخ احتياطي للقاعدة'),
        content: const Text('هل تريد إنشاء نسخة احتياطية من قاعدة البيانات؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.backupDatabase();
            },
            child: const Text('إنشاء نسخة'),
          ),
        ],
      ),
    );
  }
}
