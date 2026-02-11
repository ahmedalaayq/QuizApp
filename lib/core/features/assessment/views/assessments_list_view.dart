import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/data/assessments_data.dart';
import 'package:quiz_app/core/features/assessment/controller/assessment_controller.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_card.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessments_disclaimer_card.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessments_list_header.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentsListView extends StatelessWidget {
  const AssessmentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final assessments = [
      AssessmentsData.getDASS21Assessment(),
      AssessmentsData.getAutismAssessment(),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'الاختبارات النفسية',
          style: AppTextStyles.cairo20w700.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AssessmentsListHeader(),
            SizedBox(height: 28.h),
            ...assessments.map((assessment) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: AssessmentCard(
                  assessment: assessment,
                  onTap: () => _startAssessment(assessment),
                ),
              );
            }),
            SizedBox(height: 24.h),
            const AssessmentsDisclaimerCard(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _startAssessment(Assessment assessment) {
    Get.put(AssessmentController());
    final controller = Get.find<AssessmentController>();
    controller.initializeAssessment(assessment);
    Get.toNamed('/assessment', arguments: assessment);
  }
}
