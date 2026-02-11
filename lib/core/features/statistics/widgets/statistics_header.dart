import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StatisticsHeader extends StatelessWidget {
  const StatisticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نظرة عامة', style: AppTextStyles.cairo20w700),
        SizedBox(height: 8.h),
        Text(
          'تتبع تقدمك وتطورك عبر الوقت',
          style: AppTextStyles.cairo14w400.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
