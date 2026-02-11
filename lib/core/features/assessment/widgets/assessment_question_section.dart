import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/features/assessment/controller/assessment_controller.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_answer_tile.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_back_button.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_progress_header.dart';
import 'package:quiz_app/core/features/assessment/widgets/assessment_question_card.dart';
import 'package:quiz_app/core/models/assessment_model.dart';

class AssessmentQuestionSection extends StatelessWidget {
  final AssessmentController controller;

  const AssessmentQuestionSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currentQuestion = controller.currentAssessment
        .questions[controller.currentQuestionIndex.value];
    final progress = controller.getProgress();
    final total = controller.currentAssessment.questions.length;

    return Column(
      children: [
        AssessmentProgressHeader(
          progress: progress,
          currentIndex: controller.currentQuestionIndex.value,
          total: total,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssessmentQuestionCard(question: currentQuestion),
                SizedBox(height: 30.h),
                ..._buildAnswersList(currentQuestion),
              ],
            ),
          ),
        ),
        if (controller.currentQuestionIndex.value > 0)
          AssessmentBackButton(onPressed: controller.goBack),
      ],
    );
  }

  List<Widget> _buildAnswersList(Question currentQuestion) {
    return currentQuestion.answers.map((answer) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: AssessmentAnswerTile(
          answer: answer,
          onTap: () => controller.selectAnswer(answer, currentQuestion),
        ),
      );
    }).toList();
  }
}
