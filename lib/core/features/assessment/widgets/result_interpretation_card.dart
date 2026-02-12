import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class ResultInterpretationCard extends StatelessWidget {
  final AssessmentResult result;

  const ResultInterpretationCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1F2937)]
                  : [Colors.white, const Color(0xFFF9FAFB)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Accent Line
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(width: 14.w),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          size: 20.r,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'التحليل التفصيلي',
                        style: AppTextStyles.cairo16w700.copyWith(
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  /// Divider subtle
                  Container(
                    height: 1,
                    width: double.infinity,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                  ),

                  SizedBox(height: 16.h),

                  /// Interpretation Text
                  Text(
                    result.interpretation,
                    style: AppTextStyles.cairo14w400.copyWith(
                      color:
                          isDarkMode
                              ? Colors.grey[300]
                              : AppColors.greyDarkColor,
                      height: 1.9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
