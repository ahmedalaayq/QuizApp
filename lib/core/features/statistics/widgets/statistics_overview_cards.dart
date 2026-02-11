import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StatisticsOverviewCards extends StatelessWidget {
  const StatisticsOverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(
            'إجمالي الاختبارات',
            '${controller.totalAssessments.value}',
            Icons.assignment,
            AppColors.primaryColor,
            isDarkMode,
          ),
          _buildStatCard(
            'متوسط النتائج',
            controller.averageScore.value.toStringAsFixed(1),
            Icons.trending_up,
            Colors.green,
            isDarkMode,
          ),
          _buildStatCard(
            'آخر اختبار',
            controller.assessments.isNotEmpty
                ? _formatDate(controller.assessments.first.completionDate)
                : '-',
            Icons.calendar_today,
            Colors.orange,
            isDarkMode,
          ),
          _buildStatCard(
            'الحالة الشائعة',
            controller.mostCommonSeverity.value.isNotEmpty
                ? controller.mostCommonSeverity.value
                : '-',
            Icons.info_outline,
            Colors.blue,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(16.w),
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
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cairo12w400.copyWith(
                  color:
                      isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: AppTextStyles.cairo18w700.copyWith(
                  color: isDarkMode ? const Color(0xFFF7FAFC) : color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff < 7) return 'منذ $diff أيام';
    if (diff < 30) return 'منذ ${(diff / 7).floor()} أسابيع';
    return 'منذ ${(diff / 30).floor()} شهر';
  }
}
