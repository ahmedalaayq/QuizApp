import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/features/statistics/widgets/progress_chart_card.dart';
import 'package:quiz_app/core/features/statistics/widgets/statistics_header.dart';
import 'package:quiz_app/core/features/statistics/widgets/statistics_overview_cards.dart';
import 'package:quiz_app/core/features/statistics/widgets/recent_assessments_list.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/error_widgets.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatisticsController());
    final authService = Get.find<AuthService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF1A202C) : AppColors.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [const Color(0xFF1A202C), const Color(0xFF2D3748)]
                      : [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.8),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث البيانات',
            onPressed: () => controller.forceRefresh(),
          ),
          if (authService.isAdmin || authService.isTherapist) ...[
            // IconButton(
            //   icon: const Icon(Icons.bug_report, color: Colors.white),
            //   tooltip: 'اختبار الاتصال',
            //   onPressed: () => controller.testFirestoreConnection(),
            // ),
            // IconButton(
            //   icon: const Icon(Icons.add_circle, color: Colors.white),
            //   tooltip: 'إنشاء بيانات تجريبية',
            //   onPressed: () => controller.createSampleAssessment(),
            // ),
            IconButton(
              icon: const Icon(Icons.file_download, color: Colors.white),
              tooltip: 'تصدير التقرير',
              onPressed: () => controller.exportReport(),
            ),
          ],
          if (authService.isSuperAdmin) ...[
            // IconButton(
            //   icon: const Icon(Icons.cleaning_services, color: Colors.white),
            //   tooltip: 'تنظيف البيانات المكررة',
            //   onPressed: () => _showCleanupDialog(context, controller),
            // ),
          ],
        ],
      ),
      body:
          authService.isStudent
              ? _buildStudentView(controller, isDarkMode)
              : StreamBuilder<QuerySnapshot>(
                stream: controller.getAssessmentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  isDarkMode
                                      ? const Color(0xFFA0AEC0)
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        // Connectivity Status Banner
                        Obx(
                          () =>
                              !ConnectivityService.instance.isConnected.value
                                  ? Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.wifi_off,
                                          color: Colors.orange,
                                          size: 20.r,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            'وضع عدم الاتصال - قد تكون البيانات غير محدثة',
                                            style: AppTextStyles.cairo12w500
                                                .copyWith(color: Colors.orange),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: LoadingErrorWidget(
                            message: 'خطأ في تحميل البيانات: ${snapshot.error}',
                            onRetry: () => controller.forceRefresh(),
                          ),
                        ),
                      ],
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(isDarkMode);
                  }

                  // Process the data from stream
                  _processStreamData(snapshot.data!, controller);

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isDarkMode
                                ? [
                                  const Color(0xFF0F1419),
                                  const Color(0xFF1A202C),
                                ]
                                : [const Color(0xFFF8FAFC), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () => controller.forceRefresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildStudentView(StatisticsController controller, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF0F1419), const Color(0xFF1A202C)]
                  : [const Color(0xFFF8FAFC), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: EdgeInsets.all(32.w),
          margin: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                      : [Colors.white, const Color(0xFFFAFBFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color:
                  isDarkMode
                      ? const Color(0xFF4A5568)
                      : Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.08),
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
                child: Icon(
                  Icons.lock_outline,
                  size: 60.r,
                  color: Colors.orange,
                ),
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
                  color:
                      isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.15),
                      Colors.blue.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'يمكنك مراجعة نتائجك الشخصية في صفحة الإنجازات',
                  style: AppTextStyles.cairo12w500.copyWith(
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF0F1419), const Color(0xFF1A202C)]
                  : [const Color(0xFFF8FAFC), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
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
                  color:
                      isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[400],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'لا توجد بيانات بعد',
                style: AppTextStyles.cairo20w700.copyWith(
                  color:
                      isDarkMode
                          ? const Color(0xFFF7FAFC)
                          : AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'ابدأ بإجراء اختبار لرؤية الإحصائيات',
                style: AppTextStyles.cairo14w400.copyWith(
                  color:
                      isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Process data from Firestore stream
  void _processStreamData(
    QuerySnapshot snapshot,
    StatisticsController controller,
  ) {
    final List<AssessmentHistory> firestoreAssessments = [];
    final Set<String> seenIds =
        <String>{}; // Track seen IDs to prevent duplicates

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;

        // Check for duplicates using assessment ID or document ID
        final assessmentId = data['id'] ?? doc.id;
        if (seenIds.contains(assessmentId)) {
          continue;
        }
        seenIds.add(assessmentId);

        // Enhanced data parsing with multiple fallbacks
        DateTime completionDate;
        try {
          if (data['createdAt'] != null) {
            completionDate = (data['createdAt'] as Timestamp).toDate();
          } else if (data['timestamp'] != null) {
            completionDate = (data['timestamp'] as Timestamp).toDate();
          } else if (data['completedAt'] != null) {
            completionDate = (data['completedAt'] as Timestamp).toDate();
          } else {
            completionDate = DateTime.now();
          }
        } catch (e) {
          completionDate = DateTime.now();
        }

        // Convert Firestore data to AssessmentHistory
        final assessment = AssessmentHistory(
          id: doc.id,
          assessmentType:
              data['assessmentType'] ??
              data['assessmentId'] ??
              data['type'] ??
              'unknown',
          assessmentTitle:
              data['assessmentName'] ??
              data['assessmentTitle'] ??
              data['title'] ??
              'اختبار غير محدد',
          completionDate: completionDate,
          totalScore: (data['score'] ?? data['totalScore'] ?? 0).toInt(),
          categoryScores: Map<String, dynamic>.from(
            data['categoryScores'] ?? data['scores'] ?? {},
          ),
          overallSeverity:
              data['severity'] ??
              data['overallSeverity'] ??
              data['level'] ??
              'غير محدد',
          interpretation:
              data['interpretation'] ??
              data['result'] ??
              'لا توجد تفسيرات متاحة',
          recommendations: List<String>.from(
            data['recommendations'] ?? data['suggestions'] ?? [],
          ),
          durationInSeconds:
              (data['durationInSeconds'] ?? data['duration'] ?? 0).toInt(),
          userId: data['userId'] ?? data['user_id'],
          userName:
              data['userName'] ??
              data['user_name'] ??
              data['name'] ??
              'مستخدم غير معروف',
        );

        firestoreAssessments.add(assessment);
      } catch (e) {
        // Skip invalid documents
        continue;
      }
    }

    // Sort by completion date
    firestoreAssessments.sort(
      (a, b) => b.completionDate.compareTo(a.completionDate),
    );

    // Update controller data
    controller.assessments.value = firestoreAssessments;
    controller.calculateStatistics();
  }
}
