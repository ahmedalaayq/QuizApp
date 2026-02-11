import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentStatisticsSection extends StatelessWidget {
  final Statistics statistics;

  const StudentStatisticsSection({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات',
          style: AppTextStyles.cairo16w700,
        ),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          children: [
            _buildStatCard(
              'متوسط الدرجات',
              statistics.averageScore.toStringAsFixed(1),
              Icons.score,
            ),
            _buildStatCard(
              'الدقة',
              '${statistics.averageAccuracy.toStringAsFixed(1)}%',
              Icons.check_circle,
            ),
            _buildStatCard(
              'عدد الاختبارات',
              '${statistics.totalAssessmentsTaken}',
              Icons.assignment,
            ),
            _buildStatCard(
              'التقدم',
              '${statistics.progressPercentage.toStringAsFixed(0)}%',
              Icons.trending_up,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return CustomCard(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 28.r),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cairo12w400,
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: AppTextStyles.cairo16w700.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
