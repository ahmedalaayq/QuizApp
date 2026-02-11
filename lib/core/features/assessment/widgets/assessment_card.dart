import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentCard extends StatelessWidget {
  final Assessment assessment;
  final VoidCallback onTap;

  const AssessmentCard({
    super.key,
    required this.assessment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getAssessmentIcon(assessment.assessmentType);
    final color = _getAssessmentColor(assessment.assessmentType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      icon,
                      style: TextStyle(fontSize: 32.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.title,
                          style: AppTextStyles.cairo16w700.copyWith(
                            color: AppColors.whiteColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              color: color,
                              size: 16.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${assessment.questions.length} سؤال',
                              style: AppTextStyles.cairo12w400.copyWith(
                                color: AppColors.whiteColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 18.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                assessment.description,
                style: AppTextStyles.cairo13w400.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.85),
                  height: 1.6,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAssessmentIcon(String type) {
    switch (type.toUpperCase()) {
      case 'DASS':
        return '😔';
      case 'AUTISM':
        return '🧠';
      case 'ADHD':
        return '⚡';
      default:
        return '📋';
    }
  }

  Color _getAssessmentColor(String type) {
    switch (type.toUpperCase()) {
      case 'DASS':
        return const Color(0xFF4A90E2);
      case 'AUTISM':
        return const Color(0xFF9B59B6);
      case 'ADHD':
        return const Color(0xFFF39C12);
      default:
        return Colors.grey;
    }
  }
}
