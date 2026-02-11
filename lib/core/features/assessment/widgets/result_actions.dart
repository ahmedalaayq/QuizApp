import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/features/assessment/widgets/result_copy_share.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/pdf_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/custom_button.dart';

class ResultActions extends StatelessWidget {
  final AssessmentResult result;

  const ResultActions({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: CustomButton(
            backgroundColor: Colors.red,
            foregroundColor: AppColors.whiteColor,
            onPressed: () async {
              try {
                // Check if Hive is initialized
                if (!HiveService.isInitialized) {
                  Get.snackbar(
                    'خطأ',
                    'قاعدة البيانات المحلية غير مهيأة',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                final history = HiveService.getRecentResults(limit: 1);
                if (history.isNotEmpty) {
                  await PdfService.exportSingleReport(history.first);
                } else {
                  // Try to create a report from the current result
                  final assessmentHistory = _createAssessmentHistoryFromResult(
                    result,
                  );
                  if (assessmentHistory != null) {
                    await PdfService.exportSingleReport(assessmentHistory);
                  } else {
                    Get.snackbar(
                      'تنبيه',
                      'لا توجد نتائج محفوظة لتصديرها',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                }
              } catch (e) {
                Get.snackbar(
                  'خطأ',
                  'فشل في تصدير التقرير: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            buttonName: 'تصدير كـ PDF',
            buttonTextStyle: AppTextStyles.cairo16w700,
            radiusValue: 12.r,
          ),
        ),
        SizedBox(height: 12.h),
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
                'تم نسخ النتائج في الحافظة',
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

  AssessmentHistory? _createAssessmentHistoryFromResult(
    AssessmentResult result,
  ) {
    try {
      return AssessmentHistory(
        id: result.id,
        assessmentType: result.assessmentId,
        assessmentTitle: result.assessmentTitle,
        totalScore: result.totalScore,
        completionDate: result.completionDate,
        durationInSeconds: 300, // Default 5 minutes
        overallSeverity: result.overallSeverity,
        interpretation: result.interpretation,
        recommendations: result.recommendations,
        categoryScores: result.categoryScores.map(
          (key, value) => MapEntry(key, value as dynamic),
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error creating assessment history from result',
        e,
        stackTrace,
      );
      return null;
    }
  }
}
