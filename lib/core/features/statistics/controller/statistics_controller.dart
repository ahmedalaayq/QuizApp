import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/services/pdf_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';

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

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Wrap(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'تصدير التقرير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            const Divider(),

            // Export Full Report
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
              ),
              title: const Text('تصدير تقرير شامل'),
              onTap: () async {
                Get.back();
                await PdfService.exportFullReport(assessments);
              },
            ),

            // Print Last Report
            ListTile(
              leading: const Icon(Icons.print, color: Colors.blueAccent),
              title: const Text('طباعة آخر تقرير'),
              onTap: () async {
                Get.back();
                if (assessments.isNotEmpty) {
                  await PdfService.printReport(assessments.first);
                }
              },
            ),

            const SizedBox(height: 8),

            // Cancel Button
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.redColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void refresh() {
    loadStatistics();
  }
}
