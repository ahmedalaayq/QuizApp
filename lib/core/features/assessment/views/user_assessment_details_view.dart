import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/assessment/controller/user_assessment_details_controller.dart';
import 'package:quiz_app/core/services/animation_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class UserAssessmentDetailsView extends StatelessWidget {
  final String userId;
  final String userName;

  const UserAssessmentDetailsView({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserAssessmentDetailsController(userId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تفاصيل $userName',
          style: AppTextStyles.cairo18w700.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadUserDetails(),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.r, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  'خطأ في تحميل البيانات',
                  style: AppTextStyles.cairo18w700.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                SelectableText(
                  controller.error.value,
                  style: AppTextStyles.cairo14w400.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.loadUserDetails(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              _buildUserInfoCard(controller, isDarkMode),
              SizedBox(height: 16.h),

              // Statistics Cards
              _buildStatisticsCards(controller, isDarkMode),
              SizedBox(height: 16.h),

              // Recent Assessments
              _buildRecentAssessments(controller, isDarkMode),
              SizedBox(height: 16.h),

              // Performance Chart
              _buildPerformanceChart(controller, isDarkMode),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoCard(
    UserAssessmentDetailsController controller,
    bool isDarkMode,
  ) {
    return AnimationService.slideInFromTop(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              isDarkMode ? const Color(0xFF1A202C) : Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isDarkMode
                    ? const Color(0xFF4A5568)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: AppTextStyles.cairo20w700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.cairo18w700.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(
                        () => Text(
                          controller.userInfo['email'] ??
                              'لا يوجد بريد إلكتروني',
                          style: AppTextStyles.cairo14w400.copyWith(
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(
                        () => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(
                              controller.userInfo['role'] ?? 'student',
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _getRoleText(
                              controller.userInfo['role'] ?? 'student',
                            ),
                            style: AppTextStyles.cairo12w600.copyWith(
                              color: _getRoleColor(
                                controller.userInfo['role'] ?? 'student',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Additional Info
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    'العمر',
                    '${controller.userInfo['age'] ?? 'غير محدد'}',
                    Icons.cake,
                    isDarkMode,
                  ),
                  _buildInfoItem(
                    'الجنس',
                    controller.userInfo['gender'] ?? 'غير محدد',
                    Icons.person,
                    isDarkMode,
                  ),
                  _buildInfoItem(
                    'تاريخ التسجيل',
                    controller.getFormattedJoinDate(),
                    Icons.calendar_today,
                    isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20.r),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.cairo12w500.copyWith(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.cairo12w600.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(
    UserAssessmentDetailsController controller,
    bool isDarkMode,
  ) {
    return AnimationService.slideInFromLeft(
      Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'إجمالي الاختبارات',
              controller.totalAssessments.value.toString(),
              Icons.quiz,
              Colors.blue,
              isDarkMode,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'متوسط النتائج',
              '${controller.averageScore.value.toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.green,
              isDarkMode,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'آخر اختبار',
              controller.getLastAssessmentDate(),
              Icons.schedule,
              Colors.orange,
              isDarkMode,
            ),
          ),
        ],
      ),
      delay: const Duration(milliseconds: 200),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDarkMode ? const Color(0xFF2D3748) : Colors.white,
            isDarkMode ? const Color(0xFF1A202C) : Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.cairo16w700.copyWith(color: color)),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyles.cairo10w500.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAssessments(
    UserAssessmentDetailsController controller,
    bool isDarkMode,
  ) {
    return AnimationService.slideInFromRight(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              isDarkMode ? const Color(0xFF1A202C) : Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isDarkMode
                    ? const Color(0xFF4A5568)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primaryColor, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'الاختبارات الأخيرة',
                  style: AppTextStyles.cairo16w700.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            Obx(() {
              if (controller.recentAssessments.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد اختبارات',
                    style: AppTextStyles.cairo14w500.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentAssessments.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final assessment = controller.recentAssessments[index];
                  return _buildAssessmentTile(assessment, isDarkMode);
                },
              );
            }),
          ],
        ),
      ),
      delay: const Duration(milliseconds: 400),
    );
  }

  Widget _buildAssessmentTile(
    Map<String, dynamic> assessment,
    bool isDarkMode,
  ) {
    final score = assessment['score'] ?? 0;
    final maxScore = assessment['maxScore'] ?? 100;
    final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? const Color(0xFF4A5568).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getScoreColor(percentage).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz,
              color: _getScoreColor(percentage),
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment['assessmentName'] ?? 'اختبار غير محدد',
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  assessment['date'] ?? 'تاريخ غير محدد',
                  style: AppTextStyles.cairo12w400.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.cairo14w700.copyWith(
                  color: _getScoreColor(percentage),
                ),
              ),
              Text(
                '$score/$maxScore',
                style: AppTextStyles.cairo12w500.copyWith(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(
    UserAssessmentDetailsController controller,
    bool isDarkMode,
  ) {
    return AnimationService.slideInFromBottom(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              isDarkMode ? const Color(0xFF1A202C) : Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isDarkMode
                    ? const Color(0xFF4A5568)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primaryColor,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'الأداء عبر الوقت',
                  style: AppTextStyles.cairo16w700.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Simple performance visualization
            SizedBox(
              height: 200.h,
              child: Center(
                child: Text(
                  'رسم بياني للأداء\n(سيتم تطويره لاحقاً)',
                  style: AppTextStyles.cairo14w500.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      delay: const Duration(milliseconds: 600),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'superAdmin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'therapist':
        return Colors.orange;
      case 'student':
      default:
        return AppColors.primaryColor;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'superAdmin':
        return 'مدير عام';
      case 'admin':
        return 'مدير';
      case 'therapist':
        return 'معالج';
      case 'student':
      default:
        return 'طالب';
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
