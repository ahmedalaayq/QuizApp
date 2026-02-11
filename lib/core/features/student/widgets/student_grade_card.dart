import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentGradeCard extends StatelessWidget {
  final double grade;
  final String classification;

  const StudentGradeCard({
    super.key,
    required this.grade,
    required this.classification,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor(grade);

    return CustomCard(
      backgroundColor: gradeColor.withOpacity(0.1),
      border: Border.all(color: gradeColor, width: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'الدرجة الإجمالية',
            style: AppTextStyles.cairo14w600,
          ),
          SizedBox(height: 12.h),
          Text(
            '${grade.toStringAsFixed(2)} / 100',
            style: AppTextStyles.cairo24w700.copyWith(color: gradeColor),
          ),
          SizedBox(height: 12.h),
          Text(
            classification,
            style: AppTextStyles.cairo14w600.copyWith(color: gradeColor),
          ),
          SizedBox(height: 12.h),
          CustomProgressBar(
            value: grade / 100,
            valueColor: gradeColor,
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.amber;
    if (grade >= 70) return Colors.orange;
    if (grade >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}
