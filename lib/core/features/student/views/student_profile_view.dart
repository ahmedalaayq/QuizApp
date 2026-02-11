import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/features/student/widgets/student_grade_card.dart';
import 'package:quiz_app/core/features/student/widgets/student_info_card.dart';
import 'package:quiz_app/core/features/student/widgets/student_recent_assessments_section.dart';
import 'package:quiz_app/core/features/student/widgets/student_recommendations_section.dart';
import 'package:quiz_app/core/features/student/widgets/student_statistics_section.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/student_rating_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StudentProfileView extends StatelessWidget {
  final StudentProfile student;

  const StudentProfileView({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final report = StudentRatingService.generateStudentReport(student);
    final grade = StudentRatingService.calculateStudentGrade(report.statistics);
    final classification =
        StudentRatingService.classifyStudent(report.statistics);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'ملف الطالب',
          style: AppTextStyles.cairo18w600.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudentInfoCard(student: student),
            SizedBox(height: 20.h),
            StudentGradeCard(
              grade: grade,
              classification: classification,
            ),
            SizedBox(height: 20.h),
            StudentStatisticsSection(statistics: report.statistics),
            SizedBox(height: 20.h),
            StudentRecentAssessmentsSection(
              assessments: report.recentAssessments,
            ),
            SizedBox(height: 20.h),
            StudentRecommendationsSection(
              recommendations: report.recommendations,
            ),
          ],
        ),
      ),
    );
  }
}
