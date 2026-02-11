import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/features/statistics/widgets/progress_chart_card.dart';
import 'package:quiz_app/core/features/statistics/widgets/statistics_header.dart';
import 'package:quiz_app/core/features/statistics/widgets/statistics_overview_cards.dart';
import 'package:quiz_app/core/features/statistics/widgets/recent_assessments_list.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatisticsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        title: Text(
          'الإحصائيات والتقارير',
          style: AppTextStyles.cairo20w700.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: AppColors.whiteColor),
            tooltip: 'تصدير التقرير',
            onPressed: () => controller.exportReport(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.assessments.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatisticsHeader(),
              SizedBox(height: 20.h),
              const StatisticsOverviewCards(),
              SizedBox(height: 24.h),
              const ProgressChartCard(),
              SizedBox(height: 24.h),
              const RecentAssessmentsList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 100.r, color: Colors.grey[400]),
          SizedBox(height: 20.h),
          Text(
            'لا توجد بيانات بعد',
            style: AppTextStyles.cairo20w700.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          Text(
            'ابدأ بإجراء اختبار لرؤية الإحصائيات',
            style: AppTextStyles.cairo14w400.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/assessments-list'),
            icon: const Icon(Icons.add),
            label: const Text('ابدأ اختبار جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            ),
          ),
        ],
      ),
    );
  }
}
