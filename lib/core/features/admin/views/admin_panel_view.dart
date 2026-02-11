import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/admin/controller/admin_controller.dart';
import 'package:quiz_app/core/features/admin/widgets/admin_analytics_tab.dart';
import 'package:quiz_app/core/features/admin/widgets/admin_dashboard_tab.dart';
import 'package:quiz_app/core/features/admin/widgets/admin_notifications_tab.dart';
import 'package:quiz_app/core/features/admin/widgets/admin_system_settings_tab.dart';
import 'package:quiz_app/core/features/admin/widgets/admin_users_tab.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/error_widgets.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final authService = Get.find<AuthService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine available tabs based on user role
    final List<Tab> availableTabs = [
      const Tab(icon: Icon(Icons.dashboard), text: 'لوحة المعلومات'),
      const Tab(icon: Icon(Icons.people), text: 'المستخدمين'),
      if (authService.isSuperAdmin)
        const Tab(icon: Icon(Icons.settings), text: 'إعدادات النظام'),
      const Tab(icon: Icon(Icons.analytics), text: 'التحليلات'),
      if (authService.isSuperAdmin)
        const Tab(icon: Icon(Icons.notifications), text: 'الإشعارات'),
    ];

    return DefaultTabController(
      length: availableTabs.length,
      child: Scaffold(
        backgroundColor:
            isDarkMode
                ? Theme.of(context).scaffoldBackgroundColor
                : AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor:
              isDarkMode ? const Color(0xFF1A202C) : AppColors.primaryColor,
          elevation: 2,
          title: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 24.r),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'لوحة التحكم الإدارية',
                  style: AppTextStyles.cairo18w700.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // System Health Indicator
            Obx(
              () => Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getHealthColor(
                    controller.systemHealth.value,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      color: _getHealthColor(controller.systemHealth.value),
                      size: 16.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      controller.systemHealth.value,
                      style: AppTextStyles.cairo12w600.copyWith(
                        color: _getHealthColor(controller.systemHealth.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => controller.loadDashboardData(),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: availableTabs,
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          if (controller.error.value.isNotEmpty) {
            return LoadingErrorWidget(
              message: controller.error.value,
              onRetry: () => controller.loadDashboardData(),
            );
          }

          return TabBarView(
            children: [
              AdminDashboardTab(controller: controller, isDarkMode: isDarkMode),
              AdminUsersTab(controller: controller, isDarkMode: isDarkMode),
              if (authService.isSuperAdmin)
                AdminSystemSettingsTab(
                  controller: controller,
                  isDarkMode: isDarkMode,
                  authService: authService,
                ),
              AdminAnalyticsTab(controller: controller, isDarkMode: isDarkMode),
              if (authService.isSuperAdmin)
                AdminNotificationsTab(
                  controller: controller,
                  isDarkMode: isDarkMode,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل بيانات لوحة التحكم...',
            style: AppTextStyles.cairo16w600,
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(String health) {
    switch (health) {
      case 'ممتاز':
        return Colors.green;
      case 'جيد':
        return Colors.blue;
      case 'متوسط':
        return Colors.orange;
      case 'يحتاج تحسين':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
