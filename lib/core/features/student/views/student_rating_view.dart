import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/student/controller/student_controller.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/student_rating_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentRatingView extends StatefulWidget {
  final List<StudentProfile>? students;

  const StudentRatingView({super.key, this.students});

  @override
  State<StudentRatingView> createState() => _StudentRatingViewState();
}

class _StudentRatingViewState extends State<StudentRatingView> {
  late List<StudentProfile> _students;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();

    if (widget.students != null && widget.students!.isNotEmpty) {
      _students = widget.students!;
    } else {
      try {
        final controller = Get.find<StudentController>();
        _students = controller.students.toList();
      } catch (e) {
        _students = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topStudents = StudentRatingService.getTopStudents(
      _students,
      limit: 10,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'تقييم الطلاب',
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
            _buildSummarySection(),
            SizedBox(height: 24.h),

            _buildFilterSection(),
            SizedBox(height: 16.h),

            _buildRankedStudentsList(topStudents),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalStudents = _students.length;
    final completedAssessments = _students.fold<int>(
      0,
      (sum, student) => sum + student.getCompletedAssessmentsCount(),
    );
    final averageGrade =
        _students.isEmpty
            ? 0.0
            : _students.fold<double>(0, (sum, student) {
                  final report = StudentRatingService.generateStudentReport(
                    student,
                  );
                  return sum +
                      StudentRatingService.calculateStudentGrade(
                        report.statistics,
                      );
                }) /
                _students.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ملخص الأداء العام', style: AppTextStyles.cairo16w700),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          children: [
            _buildSummaryCard(
              'عدد الطلاب',
              '$totalStudents',
              Icons.people,
              Colors.blue,
            ),
            _buildSummaryCard(
              'الاختبارات',
              '$completedAssessments',
              Icons.assignment,
              Colors.green,
            ),
            _buildSummaryCard(
              'المتوسط',
              averageGrade.toStringAsFixed(1),
              Icons.trending_up,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      backgroundColor: color.withOpacity(0.1),
      border: Border.all(color: color, width: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24.r),
          Column(
            children: [
              Text(
                value,
                style: AppTextStyles.cairo16w700.copyWith(color: color),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: AppTextStyles.cairo10w400,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final levels = ['الكل', 'مبتدئ', 'متوسط', 'متقدم'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تصفية حسب المستوى', style: AppTextStyles.cairo14w600),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                levels.map((level) {
                  final isSelected = _selectedFilter == level;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: CustomElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = level;
                        });
                      },
                      label: level,
                      backgroundColor:
                          isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[300]!,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRankedStudentsList(List<StudentProfile> rankedStudents) {
    List<StudentProfile> filteredStudents = rankedStudents;
    if (_selectedFilter != 'الكل') {
      filteredStudents =
          rankedStudents
              .where((student) => student.currentLevel == _selectedFilter)
              .toList();
    }

    if (filteredStudents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.person_off, color: Colors.grey, size: 48.r),
              SizedBox(height: 16.h),
              Text(
                'لا توجد بيانات',
                style: AppTextStyles.cairo16w600.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ترتيب الطلاب (أفضل الأداء)', style: AppTextStyles.cairo16w700),
        SizedBox(height: 12.h),
        ...List.generate(filteredStudents.length, (index) {
          final student = filteredStudents[index];
          final report = StudentRatingService.generateStudentReport(student);
          final grade = StudentRatingService.calculateStudentGrade(
            report.statistics,
          );
          final classification = StudentRatingService.classifyStudent(
            report.statistics,
          );
          final isMedal = index < 3;

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildStudentRankCard(
              rank: index + 1,
              student: student,
              grade: grade,
              classification: classification,
              showMedal: isMedal,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStudentRankCard({
    required int rank,
    required StudentProfile student,
    required double grade,
    required String classification,
    required bool showMedal,
  }) {
    final gradeColor = _getGradeColor(grade);
    String medalEmoji = '';
    if (showMedal && rank == 1) {
      medalEmoji = '🥇';
    } else if (showMedal && rank == 2) {
      medalEmoji = '🥈';
    } else if (showMedal && rank == 3) {
      medalEmoji = '🥉';
    }

    return CustomCard(
      backgroundColor: Colors.white,
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                medalEmoji.isEmpty ? '#$rank' : medalEmoji,
                style: AppTextStyles.cairo16w700.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTextStyles.cairo14w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        student.currentLevel,
                        style: AppTextStyles.cairo10w400,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${student.getCompletedAssessmentsCount()} اختبارات',
                      style: AppTextStyles.cairo10w400.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                grade.toStringAsFixed(1),
                style: AppTextStyles.cairo16w700.copyWith(color: gradeColor),
              ),
              SizedBox(height: 4.h),
              Text(
                classification,
                style: AppTextStyles.cairo11w400.copyWith(color: gradeColor),
              ),
            ],
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
