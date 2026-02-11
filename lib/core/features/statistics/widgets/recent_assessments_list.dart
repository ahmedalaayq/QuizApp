import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:intl/intl.dart';

class RecentAssessmentsList extends StatelessWidget {
  const RecentAssessmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.assessments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'آخر الاختبارات',
            style: AppTextStyles.cairo18w700.copyWith(
              color:
                  isDarkMode ? const Color(0xFFF7FAFC) : AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 12.h),
          ...controller.assessments.take(5).map((assessment) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 12.h),
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
                borderRadius: BorderRadius.circular(12.r),
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
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getSeverityColor(
                            assessment.overallSeverity,
                          ).withValues(alpha: 0.2),
                          _getSeverityColor(
                            assessment.overallSeverity,
                          ).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        _getAssessmentIcon(assessment.assessmentType),
                        color: _getSeverityColor(assessment.overallSeverity),
                        size: 24.r,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.assessmentTitle,
                          style: AppTextStyles.cairo14w600.copyWith(
                            color:
                                isDarkMode
                                    ? const Color(0xFFF7FAFC)
                                    : AppColors.primaryDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(assessment.completionDate),
                          style: AppTextStyles.cairo12w400.copyWith(
                            color:
                                isDarkMode
                                    ? const Color(0xFFA0AEC0)
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getSeverityColor(
                            assessment.overallSeverity,
                          ).withValues(alpha: 0.2),
                          _getSeverityColor(
                            assessment.overallSeverity,
                          ).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      assessment.overallSeverity,
                      style: AppTextStyles.cairo12w600.copyWith(
                        color: _getSeverityColor(assessment.overallSeverity),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  IconData _getAssessmentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dass':
        return Icons.psychology;
      case 'autism':
        return Icons.accessibility_new;
      default:
        return Icons.quiz;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'طبيعي':
      case 'normal':
        return Colors.green;
      case 'خفيف':
      case 'mild':
        return Colors.lightGreen;
      case 'معتدل':
      case 'moderate':
        return Colors.orange;
      case 'شديد':
      case 'severe':
        return Colors.deepOrange;
      case 'شديد جداً':
      case 'extremely severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
