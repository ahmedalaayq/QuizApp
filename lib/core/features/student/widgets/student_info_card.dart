import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentInfoCard extends StatelessWidget {
  final StudentProfile student;

  const StudentInfoCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: AppColors.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            student.name,
            style: AppTextStyles.cairo20w700.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.email,
            student.email,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            Icons.calendar_today,
            'تاريخ التسجيل: ${student.registrationDate.day}/${student.registrationDate.month}/${student.registrationDate.year}',
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'المستوى: ${student.currentLevel}',
              style: AppTextStyles.cairo12w600.copyWith(
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.whiteColor, size: 18.r),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.cairo12w400.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ],
    );
  }
}
