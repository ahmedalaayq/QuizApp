import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/features/achievements/services/achievement_service.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/services/assessment_analysis_service.dart';
import 'package:uuid/uuid.dart';

class AssessmentController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var responses = <UserResponse>[].obs;
  var isLoading = false.obs;
  var isStarted = false.obs;
  var startTime = DateTime.now();

  late Assessment currentAssessment;
  AssessmentResult? assessmentResult;

  void initializeAssessment(Assessment assessment) {
    currentAssessment = assessment;
    currentQuestionIndex.value = 0;
    responses.clear();
    isStarted.value = false;
    startTime = DateTime.now();
  }

  void startAssessment() {
    isStarted.value = true;
    startTime = DateTime.now();
  }

  void selectAnswer(Answer answer, Question question) {
    final response = UserResponse(
      questionId: question.id,
      answerId: answer.id,
      answerText: answer.text,
      score: answer.score,
      category: question.category,
    );

    responses.add(response);

    if (currentQuestionIndex.value < currentAssessment.questions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      submitAssessment();
    }
  }

  void submitAssessment() async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));

    if (currentAssessment.assessmentType == 'DASS') {
      assessmentResult = AssessmentAnalysisService.analyzeDASS21(
        currentAssessment,
        responses,
      );
    } else if (currentAssessment.assessmentType == 'AUTISM') {
      assessmentResult = AssessmentAnalysisService.analyzeAutism(
        currentAssessment,
        responses,
      );
    }

    if (assessmentResult != null) {
      await _saveResult(assessmentResult!);

      final newAchievements = await AchievementService.checkAchievements();
      for (var achievement in newAchievements) {
        AchievementService.showAchievementNotification(achievement);
      }
    }

    isLoading.value = false;
    Get.toNamed('/assessment-result', arguments: assessmentResult);
  }

  Future<void> _saveResult(AssessmentResult result) async {
    final duration = DateTime.now().difference(startTime).inSeconds;

    final history = AssessmentHistory(
      id: const Uuid().v4(),
      assessmentType: currentAssessment.assessmentType,
      assessmentTitle: currentAssessment.title,
      completionDate: DateTime.now(),
      totalScore: result.totalScore,
      categoryScores: result.categoryScores,
      overallSeverity: result.overallSeverity,
      interpretation: result.interpretation,
      recommendations: result.recommendations,
      durationInSeconds: duration,
    );

    await HiveService.saveAssessmentResult(history);
  }

  void goBack() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      responses.removeAt(responses.length - 1);
    }
  }

  double getProgress() {
    return (currentQuestionIndex.value + 1) /
        currentAssessment.questions.length;
  }
}
