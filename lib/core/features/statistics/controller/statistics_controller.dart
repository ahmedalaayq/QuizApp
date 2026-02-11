import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/services/pdf_service.dart';

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

  
    final total = assessments.fold<int>(
      0,
      (sum, item) => sum + item.totalScore,
    );
    averageScore.value = total / assessments.length;

  
    final severityMap = <String, int>{};
    for (var assessment in assessments) {
      severityMap[assessment.overallSeverity] =
          (severityMap[assessment.overallSeverity] ?? 0) + 1;
    }
    mostCommonSeverity.value =
        severityMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> exportReport() async {
    if (assessments.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد بيانات لتصديرها',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

  
    Get.dialog(
      AlertDialog(
        title: const Text('تصدير التقرير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('تصدير تقرير شامل'),
              onTap: () async {
                Get.back();
                await PdfService.exportFullReport(assessments);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('طباعة آخر تقرير'),
              onTap: () async {
                Get.back();
                if (assessments.isNotEmpty) {
                  await PdfService.printReport(assessments.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void refresh() {
    loadStatistics();
  }
}
