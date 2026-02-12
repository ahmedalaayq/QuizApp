import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_actions.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_category_scores_section.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_interpretation_card.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_recommendations_section.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_severity_card.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentResultView extends StatelessWidget {
  const AssessmentResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final AssessmentResult result = Get.arguments as AssessmentResult;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1A202C) : AppColors.primaryColor,
        elevation: 2,
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        title: Text(
          'النتائج',
          style: AppTextStyles.cairo18w700.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.assessmentTitle,
              style: AppTextStyles.cairo20w700.copyWith(
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 20.h),

            ResultSeverityCard(result: result),
            SizedBox(height: 20.h),

            ResultCategoryScoresSection(result: result),
            SizedBox(height: 25.h),

            ResultInterpretationCard(result: result),
            SizedBox(height: 25.h),

            ResultRecommendationsSection(result: result),
            SizedBox(height: 30.h),

            ResultActions(result: result),
          ],
        ),
      ),
    );
  }
}
