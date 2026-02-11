import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/features/assessment/controller/assessment_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_button.dart';

class AssessmentIntroScreen extends StatelessWidget {
  final AssessmentController controller;

  const AssessmentIntroScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 40.h),
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assessment,
                  size: 60.r,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                controller.currentAssessment.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.cairo24w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                controller.currentAssessment.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.cairo14w400.copyWith(
                  color: isDarkMode ? Colors.white70 : AppColors.greyDarkColor,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? AppColors.warningColor.withValues(alpha: 0.15)
                          : AppColors.warningColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.warningColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warningColor,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'معلومة مهمة',
                          style: AppTextStyles.cairo14w700.copyWith(
                            color: AppColors.warningColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'هذا الاختبار لأغراض تقييم نفسي فقط. النتائج لا تُعد تشخيصاً طبياً رسمياً.\n\nيُفضّل استشارة مختص نفسي أو طبيب للحصول على تقييم شامل ودقيق.',
                      style: AppTextStyles.cairo12w400.copyWith(
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryDark,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          CustomButton(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.whiteColor,
            onPressed: controller.startAssessment,
            buttonName: 'ابدأ الآن',
            buttonTextStyle: AppTextStyles.cairo18w700,
            radiusValue: 12.r,
          ),
        ],
      ),
    );
  }
}
