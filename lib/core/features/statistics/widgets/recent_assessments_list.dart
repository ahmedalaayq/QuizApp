import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:intl/intl.dart';

class RecentAssessmentsList extends StatelessWidget {
  const RecentAssessmentsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();

    return Obx(() {
      if (controller.assessments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('آخر الاختبارات', style: AppTextStyles.cairo18w700),
          SizedBox(height: 12.h),
          ...controller.assessments.take(5).map((assessment) {
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: _getSeverityColor(
                        assessment.overallSeverity,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        _getAssessmentIcon(assessment.assessmentType),
                        style: TextStyle(fontSize: 24.sp),
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
                          style: AppTextStyles.cairo14w600,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(assessment.completionDate),
                          style: AppTextStyles.cairo12w400.copyWith(
                            color: Colors.grey[600],
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
                      color: _getSeverityColor(
                        assessment.overallSeverity,
                      ).withOpacity(0.1),
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

  String _getAssessmentIcon(String type) {
    switch (type.toUpperCase()) {
      case 'DASS':
        return '😔';
      case 'AUTISM':
        return '🧠';
      default:
        return '📋';
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
