import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class ResultCategoryScoresSection extends StatelessWidget {
  final AssessmentResult result;

  const ResultCategoryScoresSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفصيل النتائج',
          style: AppTextStyles.cairo18w700.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 15.h),
        ...result.categoryScores.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _CategoryScoreBar(category: entry.key, score: entry.value),
          );
        }),
      ],
    );
  }
}

class _CategoryScoreBar extends StatelessWidget {
  final String category;
  final int score;

  const _CategoryScoreBar({required this.category, required this.score});

  @override
  Widget build(BuildContext context) {
    const maxScore = 60;
    final percentage = (score / maxScore).clamp(0.0, 1.0);
    final barColor = _getScoreColor(percentage);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3748) : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: barColor.withOpacity(0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: AppTextStyles.cairo14w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '$score/$maxScore',
                  style: AppTextStyles.cairo12w700.copyWith(color: barColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8.h,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              backgroundColor:
                  isDarkMode
                      ? const Color(0xFF4A5568)
                      : AppColors.greyLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage < 0.25) return AppColors.excellentColor;
    if (percentage < 0.5) return AppColors.goodColor;
    if (percentage < 0.75) return AppColors.warningColor;
    if (percentage < 0.9) return AppColors.criticalColor.withOpacity(0.8);
    return AppColors.criticalColor;
  }
}
