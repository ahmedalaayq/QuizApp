import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_copy_share.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_button.dart';

class ResultActions extends StatelessWidget {
  final AssessmentResult result;

  const ResultActions({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: CustomButton(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.whiteColor,
            onPressed: () => Get.offAllNamed(AppRoutes.home),
            buttonName: 'العودة للرئيسية',
            buttonTextStyle: AppTextStyles.cairo16w700,
            radiusValue: 12.r,
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: CustomButton(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primaryColor,
            onPressed: () async {
              await ResultCopyShare.copyToClipboard(result);
              Get.snackbar(
                'تم النسخ',
                'اتنسخت النتائج في الحافظة—تقدر تبعتها لأي حد.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            buttonName: 'نسخ النتائج للمشاركة',
            buttonTextStyle: AppTextStyles.cairo16w700,
            radiusValue: 12.r,
          ),
        ),
      ],
    );
  }
}

