import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/features/statistics/widgets/progress_chart_card.dart';
import 'package:quiz_app/core/features/statistics/widgets/statistics_header.dart';
import 'package:quiz_app/core/features/statistics/widgets/statistics_overview_cards.dart';
import 'package:quiz_app/core/features/statistics/widgets/recent_assessments_list.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatisticsController());
    final authService = Get.find<AuthService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1A202C) : AppColors.primaryColor,
        elevation: 2,
        title: Text(
          'الإحصائيات والتقارير',
          style: AppTextStyles.cairo20w700.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (authService.isAdmin || authService.isTherapist)
            IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white),
              tooltip: 'تصدير التقرير',
              onPressed: () => controller.exportReport(),
            ),
        ],
      ),
      body: Obx(() {
        // Check user permissions
        if (authService.isStudent) {
          return _buildStudentView(controller, isDarkMode);
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
                  'جاري تحميل الإحصائيات...',
                  style: AppTextStyles.cairo16w600.copyWith(
                    color:
                        isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.assessments.isEmpty) {
          return _buildEmptyState(isDarkMode);
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

  Widget _buildStudentView(StatisticsController controller, bool isDarkMode) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: EdgeInsets.all(32.w),
        margin: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isDarkMode
                    ? const Color(0xFF4A5568)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.2),
                    Colors.orange.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline, size: 60.r, color: Colors.orange),
            ),
            SizedBox(height: 24.h),
            Text(
              'الإحصائيات الشاملة',
              style: AppTextStyles.cairo20w700.copyWith(
                color:
                    isDarkMode
                        ? const Color(0xFFF7FAFC)
                        : AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'هذه الميزة متاحة فقط للمعالجين النفسيين ومديري النظام',
              style: AppTextStyles.cairo14w400.copyWith(
                color: isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'يمكنك مراجعة نتائجك الشخصية في صفحة الإنجازات',
                style: AppTextStyles.cairo12w500.copyWith(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/achievements'),
              icon: const Icon(Icons.emoji_events),
              label: const Text('عرض إنجازاتي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withValues(alpha: 0.2),
                    Colors.grey.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assessment_outlined,
                size: 80.r,
                color: isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[400],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد بيانات بعد',
              style: AppTextStyles.cairo20w700.copyWith(
                color: isDarkMode ? const Color(0xFFF7FAFC) : Colors.grey[600],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'ابدأ بإجراء اختبار لرؤية الإحصائيات',
              style: AppTextStyles.cairo14w400.copyWith(
                color: isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/assessments-list'),
              icon: const Icon(Icons.add),
              label: const Text('ابدأ اختبار جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
