import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class HomeImportantNoticeCard extends StatelessWidget {
  const HomeImportantNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warningColor.withOpacity(0.08),
        border: Border.all(
          color: AppColors.warningColor.withOpacity(0.28),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.warningColor,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'تنويه مهم',
                  style: AppTextStyles.cairo14w700.copyWith(
                    color: AppColors.warningColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'هذه الاختبارات لأغراض توعوية وتقييمية فقط. النتائج لا تُعد تشخيصاً طبياً رسمياً. يُفضّل استشارة مختص نفسي/عصبي معتمد للحصول على تقييم شامل وخطة متابعة.',
            style: AppTextStyles.cairo12w400.copyWith(
              color: AppColors.primaryDark,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
