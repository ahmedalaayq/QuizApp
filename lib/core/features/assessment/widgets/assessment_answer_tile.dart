import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentAnswerTile extends StatelessWidget {
  final Answer answer;
  final VoidCallback onTap;

  const AssessmentAnswerTile({
    super.key,
    required this.answer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primaryLight,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                  color: AppColors.primaryLight.withOpacity(0.5),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  answer.text,
                  style: AppTextStyles.cairo14w500.copyWith(
                    color: AppColors.primaryDark,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

