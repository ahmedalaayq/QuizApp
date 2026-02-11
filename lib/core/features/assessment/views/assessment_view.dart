import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/assessment/controller/assessment_controller.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_app_bar.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_intro_screen.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_question_section.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentView extends StatelessWidget {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final AssessmentController controller = Get.find();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.backgroundColor,
      appBar: AssessmentAppBar(title: controller.currentAssessment.title),
      body: Obx(() {
        if (!controller.isStarted.value) {
          return AssessmentIntroScreen(controller: controller);
        }

        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'جاري تحليل النتائج...',
                  style: AppTextStyles.cairo16w600.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          );
        }

        return AssessmentQuestionSection(controller: controller);
      }),
    );
  }
}
