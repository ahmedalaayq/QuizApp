import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_button.dart';

class AssessmentBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AssessmentBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50),
      child: CustomButton(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryColor,
        onPressed: onPressed,
        buttonName: 'رجوع',
        buttonTextStyle: AppTextStyles.cairo16w700,
        radiusValue: 12.r,
      ),
    );
  }
}
