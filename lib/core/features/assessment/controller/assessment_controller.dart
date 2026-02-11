import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/features/achievements/services/achievement_service.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/services/assessment_analysis_service.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:uuid/uuid.dart';

class AssessmentController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var responses = <UserResponse>[].obs;
  var isLoading = false.obs;
  var isStarted = false.obs;
  var selectedAnswerId = ''.obs;
  var startTime = DateTime.now();

  late Assessment currentAssessment;
  AssessmentResult? assessmentResult;

  void initializeAssessment(Assessment assessment) {
    currentAssessment = assessment;
    currentQuestionIndex.value = 0;
    responses.clear();
    isStarted.value = false;
    selectedAnswerId.value = '';
    startTime = DateTime.now();
  }

  void startAssessment() {
    isStarted.value = true;
    startTime = DateTime.now();
  }

  void selectAnswer(Answer answer, Question question) {
    selectedAnswerId.value = answer.id;

    // Add a small delay to show selection feedback
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = UserResponse(
        questionId: question.id,
        answerId: answer.id,
        answerText: answer.text,
        score: answer.score,
        category: question.category,
      );

      responses.add(response);
      selectedAnswerId.value = '';

      if (currentQuestionIndex.value < currentAssessment.questions.length - 1) {
        currentQuestionIndex.value++;
      } else {
        submitAssessment();
      }
    });
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
    final authService = Get.find<AuthService>();
    final connectivityService = Get.find<ConnectivityService>();

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

    // Save locally first
    try {
      await HiveService.saveAssessmentResult(history);
      LoggerService.info('Assessment result saved locally successfully');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to save assessment result locally',
        e,
        stackTrace,
      );
    }

    // Save to Firebase if connected and user is logged in
    if (connectivityService.isConnected.value && authService.isLoggedIn.value) {
      try {
        LoggerService.info('Attempting to save assessment result to Firebase');

        final firestoreData = {
          'id': history.id,
          'userId': authService.currentUserId,
          'assessmentType': history.assessmentType,
          'assessmentTitle': history.assessmentTitle,
          'completionDate': history.completionDate.toIso8601String(),
          'totalScore': history.totalScore,
          'categoryScores': Map<String, dynamic>.from(history.categoryScores),
          'overallSeverity': history.overallSeverity,
          'interpretation': history.interpretation,
          'recommendations': List<String>.from(history.recommendations),
          'durationInSeconds': history.durationInSeconds,
        };

        LoggerService.info(
          'Firestore data prepared: ${firestoreData.keys.join(', ')}',
        );

        await FirebaseService.saveAssessmentResult(firestoreData);
        LoggerService.info('Assessment result saved to Firebase successfully');
      } catch (e, stackTrace) {
        LoggerService.error(
          'Failed to save assessment result to Firebase',
          e,
          stackTrace,
        );

        // Show user-friendly error message
        Get.snackbar(
          'تنبيه',
          'تم حفظ النتيجة محلياً، لكن فشل في الحفظ السحابي. تحقق من الاتصال.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:
              Get.isDarkMode ? const Color(0xFF21262D) : Colors.orange,
          colorText: Get.isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      LoggerService.warning(
        'Skipping Firebase save - not connected or not logged in',
      );
    }
  }

  void goBack() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      responses.removeAt(responses.length - 1);
      selectedAnswerId.value = '';
    }
  }

  double getProgress() {
    return (currentQuestionIndex.value + 1) /
        currentAssessment.questions.length;
  }
}
