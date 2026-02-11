import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentsDisclaimerCard extends StatelessWidget {
  const AssessmentsDisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(
          color: const Color(0xFFF57C00),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.info_outline,
              color: const Color(0xFFF57C00),
              size: 24.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنويه مهم',
                  style: AppTextStyles.cairo16w700.copyWith(
                    color: const Color(0xFFF57C00),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'هذه الاختبارات لأغراض تقييمية وتوعوية فقط. النتائج لا تعتبر تشخيصاً طبياً رسمياً ولا تغني عن استشارة متخصص نفسي معتمد.',
                  style: AppTextStyles.cairo13w400.copyWith(
                    color: const Color(0xFF5D4037),
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
