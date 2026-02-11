import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentQuestionCard extends StatelessWidget {
  final Question question;

  const AssessmentQuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primaryLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        question.text,
        style: AppTextStyles.cairo16w700.copyWith(
          color: AppColors.primaryDark,
          height: 1.7,
        ),
      ),
    );
  }
}

