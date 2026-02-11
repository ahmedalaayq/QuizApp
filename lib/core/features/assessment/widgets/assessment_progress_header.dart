import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/theme_controller.dart';

class AssessmentProgressHeader extends StatelessWidget {
  final double progress;
  final int currentIndex;
  final int total;

  const AssessmentProgressHeader({
    super.key,
    required this.progress,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 8.h,
          color: AppColors.primaryColor.withOpacity(0.10),
          child: LinearProgressIndicator(
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            backgroundColor: Colors.transparent,
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال ${currentIndex + 1} من $total',
                style: AppTextStyles.cairo14w600.copyWith(
                  color:
                      Get.isDarkMode
                          ? AppColors.backgroundColor
                          : AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.cairo12w700.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
