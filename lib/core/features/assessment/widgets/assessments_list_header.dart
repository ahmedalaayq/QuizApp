import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentsListHeader extends StatelessWidget {
  const AssessmentsListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الاختبار المناسب',
          style: AppTextStyles.cairo20w700.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'اختر أحد الاختبارات النفسية المعتمدة لتقييم حالتك',
          style: AppTextStyles.cairo14w400.copyWith(
            color: AppColors.whiteColor.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
