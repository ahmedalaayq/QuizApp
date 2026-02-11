import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentRecentAssessmentsSection extends StatelessWidget {
  final List<StudentAssessment> assessments;

  const StudentRecentAssessmentsSection({
    super.key,
    required this.assessments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'آخر الاختبارات',
          style: AppTextStyles.cairo16w700,
        ),
        SizedBox(height: 12.h),
        ...assessments.map((assessment) {
          final percentage = assessment.getPercentageScore();
          final color = _getGradeColor(percentage);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CustomCard(
              backgroundColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          assessment.assessmentTitle,
                          style: AppTextStyles.cairo14w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          assessment.getPerformanceRating(),
                          style: AppTextStyles.cairo11w400.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التاريخ: ${assessment.completionDate.day}/${assessment.completionDate.month}/${assessment.completionDate.year}',
                        style: AppTextStyles.cairo11w400.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        assessment.getFormattedTime(),
                        style: AppTextStyles.cairo11w400.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomProgressBar(
                    value: percentage / 100,
                    label: '${percentage.toStringAsFixed(1)}%',
                    valueColor: color,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.amber;
    if (grade >= 70) return Colors.orange;
    if (grade >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}
