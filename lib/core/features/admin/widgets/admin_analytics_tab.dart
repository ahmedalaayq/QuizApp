import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/features/admin/controller/admin_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';

class AdminAnalyticsTab extends StatelessWidget {
  final AdminController controller;
  final bool isDarkMode;

  const AdminAnalyticsTab({
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
          // Analytics Overview
          _buildAnalyticsOverview(),
          SizedBox(height: 24.h),

          // Usage Statistics
          _buildUsageStatistics(),
          SizedBox(height: 24.h),

          // Performance Metrics
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: constraints.maxWidth > 600 ? 1.3 : 1.5,
          children: [
            _buildAnalyticsCard(
              'تقييمات اليوم',
              '${controller.todayAssessments.value}',
              Icons.today,
              Colors.green,
            ),
            _buildAnalyticsCard(
              'تقييمات الأسبوع',
              '${controller.weeklyAssessments.value}',
              Icons.date_range,
              Colors.blue,
            ),
            _buildAnalyticsCard(
              'تقييمات الشهر',
              '${controller.monthlyAssessments.value}',
              Icons.calendar_month,
              Colors.orange,
            ),
            _buildAnalyticsCard(
              'صحة النظام',
              controller.systemHealth.value,
              Icons.health_and_safety,
              _getHealthColor(controller.systemHealth.value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsageStatistics() {
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
          Text(
            'إحصائيات الاستخدام',
            style: AppTextStyles.cairo18w700.copyWith(
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 16.h),

          // User Distribution Chart would go here
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? const Color(0xFF1A202C) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'مخطط توزيع المستخدمين\n(سيتم تنفيذه قريباً)',
                textAlign: TextAlign.center,
                style: AppTextStyles.cairo14w500.copyWith(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      width: double.infinity,
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
          Text(
            'مقاييس الأداء',
            style: AppTextStyles.cairo18w700.copyWith(
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 16.h),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  children: [
                    _buildMetricItem(
                      'معدل النشاط',
                      '${controller.activeUserPercentage.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      Colors.green,
                    ),
                    SizedBox(height: 12.h),
                    _buildMetricItem(
                      'متوسط التقييمات',
                      (controller.totalAssessments.value / (controller.totalUsers.value > 0 ? controller.totalUsers.value : 1)).toStringAsFixed(1),
                      Icons.assessment,
                      Colors.blue,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        'معدل النشاط',
                        '${controller.activeUserPercentage.toStringAsFixed(1)}%',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildMetricItem(
                        'متوسط التقييمات',
                        (controller.totalAssessments.value / (controller.totalUsers.value > 0 ? controller.totalUsers.value : 1)).toStringAsFixed(1),
                        Icons.assessment,
                        Colors.blue,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedCard(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(height: 8.h),
            Text(
              value,
              style: AppTextStyles.cairo18w700.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: AppTextStyles.cairo12w500.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.cairo16w700.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.cairo12w500.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
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
