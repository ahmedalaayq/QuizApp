import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/assessment/controller/assessment_controller.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_app_bar.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_intro_screen.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_question_section.dart';
import 'package:quiz_app/core/styles/app_colors.dart';

class AssessmentView extends StatelessWidget {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final AssessmentController controller = Get.find();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AssessmentAppBar(
        title: controller.currentAssessment.title,
      ),
      body: Obx(() {
        if (!controller.isStarted.value) {
          return AssessmentIntroScreen(controller: controller);
        }

        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          );
        }

        return AssessmentQuestionSection(controller: controller);
      }),
    );
  }
}
