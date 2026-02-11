import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/admin/controller/admin_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AdminNotificationsTab extends StatelessWidget {
  final AdminController controller;
  final bool isDarkMode;

  const AdminNotificationsTab({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Send Notification Section
          _buildSendNotificationSection(),
          SizedBox(height: 24.h),

          // System Alerts
          _buildSystemAlertsSection(),
        ],
      ),
    );
  }

  Widget _buildSendNotificationSection() {
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
              Icon(Icons.send, color: Colors.blue, size: 24.r),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'إرسال إشعار جماعي',
                  style: AppTextStyles.cairo18w700.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          ElevatedButton.icon(
            onPressed: () => _showNotificationDialog(),
            icon: const Icon(Icons.notifications),
            label: const Text('إنشاء إشعار جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemAlertsSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'تنبيهات النظام',
                  style: AppTextStyles.cairo18w700.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() {
                if (controller.pendingNotifications.value > 0) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${controller.pendingNotifications.value}',
                      style: AppTextStyles.cairo12w600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          SizedBox(height: 16.h),

          Obx(() {
            if (controller.systemAlerts.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد تنبيهات حالياً',
                  style: AppTextStyles.cairo14w500.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.systemAlerts.length,
              itemBuilder: (context, index) {
                final alert = controller.systemAlerts[index];
                return _buildAlertTile(alert);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAlertTile(Map<String, dynamic> alert) {
    final status = alert['status'] ?? 'pending';
    final type = alert['type'] ?? 'info';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _getAlertColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _getAlertColor(type).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_getAlertIcon(type), color: _getAlertColor(type), size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'] ?? 'تنبيه النظام',
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (alert['message'] != null)
                  Text(
                    alert['message'],
                    style: AppTextStyles.cairo12w400.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: status == 'pending' ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              status == 'pending' ? 'معلق' : 'مكتمل',
              style: AppTextStyles.cairo10w600.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedRole = 'all';

    Get.dialog(
      AlertDialog(
        title: const Text('إرسال إشعار جماعي'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الإشعار',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'محتوى الإشعار',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'المستهدفين',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('جميع المستخدمين'),
                  ),
                  DropdownMenuItem(value: 'student', child: Text('الطلاب فقط')),
                  DropdownMenuItem(
                    value: 'therapist',
                    child: Text('المعالجين فقط'),
                  ),
                  DropdownMenuItem(value: 'admin', child: Text('المديرين فقط')),
                ],
                onChanged: (value) => selectedRole = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                Get.back();
                controller.sendBroadcastNotification(
                  title: titleController.text,
                  message: messageController.text,
                  targetRole: selectedRole == 'all' ? null : selectedRole,
                );
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'info':
      default:
        return Icons.info;
    }
  }
}
