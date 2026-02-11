import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class ResultSeverityCard extends StatelessWidget {
  final AssessmentResult result;

  const ResultSeverityCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(result.overallSeverity);
    final severityIcon = _getSeverityIcon(result.overallSeverity);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: severityColor.withOpacity(0.28), width: 1.5),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: severityColor.withOpacity(0.10),
            ),
            child: Center(
              child: Text(severityIcon, style: TextStyle(fontSize: 48.r)),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'الحالة الإجمالية',
            style: AppTextStyles.cairo13w600.copyWith(
              color: AppColors.greyDarkColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            result.overallSeverity,
            style: AppTextStyles.cairo28w700.copyWith(color: severityColor),
          ),
          SizedBox(height: 12.h),
          Text(
            'الإجمالي: ${result.totalScore} نقطة',
            style: AppTextStyles.cairo14w500.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'طبيعي':
      case 'منخفض':
        return AppColors.excellentColor;
      case 'خفيف':
        return AppColors.goodColor;
      case 'معتدل':
        return AppColors.warningColor;
      case 'شديد':
        return AppColors.criticalColor;
      case 'شديد جداً':
      case 'عالي جداً':
        return AppColors.criticalColor;
      default:
        return AppColors.greyColor;
    }
  }

  String _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'طبيعي':
      case 'منخفض':
        return 'check';
      case 'خفيف':
        return 'warning';
      case 'معتدل':
        return 'warning';
      case 'شديد':
        return 'error';
      case 'شديد جداً':
      case 'عالي جداً':
        return 'alert';
      default:
        return 'question';
    }
  }
}
