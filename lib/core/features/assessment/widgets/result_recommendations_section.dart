import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class ResultRecommendationsSection extends StatelessWidget {
  final AssessmentResult result;

  const ResultRecommendationsSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التوصيات والنصائح',
          style: AppTextStyles.cairo18w700.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 15.h),
        ...result.recommendations.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF2D3748) : AppColors.whiteColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color:
                      isDarkMode
                          ? const Color(0xFF4A5568)
                          : AppColors.primaryLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.primaryDark],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTextStyles.cairo12w700.copyWith(
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.cairo12w400.copyWith(
                        color:
                            isDarkMode
                                ? Colors.grey[300]
                                : AppColors.primaryDark,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
