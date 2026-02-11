import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';

class StatisticsController extends GetxController {
  final RxList<AssessmentHistory> assessments = <AssessmentHistory>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalAssessments = 0.obs;
  final RxDouble averageScore = 0.0.obs;
  final RxString mostCommonSeverity = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  void loadStatistics() {
    isLoading.value = true;
    try {
      assessments.value = HiveService.getAllResults();
      _calculateStatistics();
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStatistics() {
    if (assessments.isEmpty) return;

    totalAssessments.value = assessments.length;

    // حساب المتوسط
    final total = assessments.fold<int>(
      0,
      (sum, item) => sum + item.totalScore,
    );
    averageScore.value = total / assessments.length;

    // الشدة الأكثر شيوعاً
    final severityMap = <String, int>{};
    for (var assessment in assessments) {
      severityMap[assessment.overallSeverity] =
          (severityMap[assessment.overallSeverity] ?? 0) + 1;
    }
    mostCommonSeverity.value =
        severityMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> exportReport() async {
    // سيتم تنفيذها لاحقاً
    Get.snackbar(
      'قريباً',
      'ميزة تصدير التقرير قيد التطوير',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void refresh() {
    loadStatistics();
  }
}
