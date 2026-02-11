import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/student/controller/student_controller.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/student_rating_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StudentRatingView extends StatelessWidget {
  final List<StudentProfile>? students;

  const StudentRatingView({super.key, this.students});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0D1117) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'تقييم الطلاب',
          style: AppTextStyles.cairo24w700.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshStudents(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity Status Banner
          Obx(
            () =>
                !connectivityService.isConnected.value
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
                              style: AppTextStyles.cairo12w500.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState(controller);
              }

              final topStudents = controller.getTopStudents(limit: 10);

              return RefreshIndicator(
                onRefresh: () => controller.refreshStudents(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummarySection(controller, isDarkMode),
                      SizedBox(height: 24.h),
                      _buildFilterSection(controller, isDarkMode),
                      SizedBox(height: 16.h),
                      _buildRankedStudentsList(topStudents, isDarkMode),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          SizedBox(height: 16.h),
          Text('جاري تحميل بيانات الطلاب...', style: AppTextStyles.cairo16w600),
        ],
      ),
    );
  }

  Widget _buildErrorState(StudentController controller) {
    final connectivityService = Get.find<ConnectivityService>();
    final isOffline = !connectivityService.isConnected.value;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOffline ? Icons.wifi_off : Icons.error_outline,
            size: 64.r,
            color: isOffline ? Colors.orange : Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            isOffline ? 'لا يوجد اتصال بالإنترنت' : 'خطأ في تحميل البيانات',
            style: AppTextStyles.cairo18w700.copyWith(
              color: isOffline ? Colors.orange : Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.error.value,
            style: AppTextStyles.cairo14w400,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => controller.refreshStudents(),
            icon: Icon(isOffline ? Icons.refresh : Icons.refresh),
            label: Text(
              isOffline ? 'إعادة المحاولة عند الاتصال' : 'إعادة المحاولة',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isOffline ? Colors.orange : AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(StudentController controller, bool isDarkMode) {
    final students = controller.students;
    final totalStudents = students.length;
    final completedAssessments = students.fold<int>(
      0,
      (sum, student) => sum + student.getCompletedAssessmentsCount(),
    );
    final averageGrade =
        students.isEmpty
            ? 0.0
            : students.fold<double>(0, (sum, student) {
                  final report = StudentRatingService.generateStudentReport(
                    student,
                  );
                  return sum +
                      StudentRatingService.calculateStudentGrade(
                        report.statistics,
                      );
                }) /
                students.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملخص الأداء العام',
          style: AppTextStyles.cairo16w700.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
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
              isDarkMode,
            ),
            _buildSummaryCard(
              'الاختبارات',
              '$completedAssessments',
              Icons.assignment,
              Colors.green,
              isDarkMode,
            ),
            _buildSummaryCard(
              'المتوسط',
              averageGrade.toStringAsFixed(1),
              Icons.trending_up,
              Colors.orange,
              isDarkMode,
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
    bool isDarkMode,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          Column(
            children: [
              Text(
                value,
                style: AppTextStyles.cairo16w700.copyWith(color: color),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: AppTextStyles.cairo10w400.copyWith(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
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

  Widget _buildFilterSection(StudentController controller, bool isDarkMode) {
    final levels = ['الكل', 'مبتدئ', 'متوسط', 'متقدم', 'خبير'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تصفية حسب المستوى',
          style: AppTextStyles.cairo14w600.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => Row(
              children:
                  levels.map((level) {
                    final isSelected = controller.selectedFilter.value == level;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: InkWell(
                        onTap: () => controller.updateFilter(level),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primaryColor
                                    : (isDarkMode
                                        ? const Color(0xFF21262D)
                                        : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primaryColor
                                      : (isDarkMode
                                          ? const Color(0xFF30363D)
                                          : Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            level,
                            style: AppTextStyles.cairo12w600.copyWith(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white
                                          : AppColors.primaryDark),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankedStudentsList(
    List<StudentProfile> rankedStudents,
    bool isDarkMode,
  ) {
    return Obx(() {
      final selectedFilter = Get.find<StudentController>().selectedFilter.value;
      List<StudentProfile> filteredStudents = rankedStudents;

      if (selectedFilter != 'الكل') {
        filteredStudents =
            rankedStudents
                .where((s) => s.currentLevel == selectedFilter)
                .toList();
      }

      if (filteredStudents.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Column(
              children: [
                Icon(
                  Icons.person_off,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  size: 48.r,
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد بيانات',
                  style: AppTextStyles.cairo16w600.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ترتيب الطلاب (أفضل الأداء)',
            style: AppTextStyles.cairo16w700.copyWith(
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
          ),
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
                isDarkMode: isDarkMode,
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildStudentRankCard({
    required int rank,
    required StudentProfile student,
    required double grade,
    required String classification,
    required bool showMedal,
    required bool isDarkMode,
  }) {
    final gradeColor = _getGradeColor(grade);

    IconData? medalIcon;
    Color? medalColor;

    if (showMedal && rank == 1) {
      medalIcon = Icons.emoji_events;
      medalColor = Colors.amber[700];
    } else if (showMedal && rank == 2) {
      medalIcon = Icons.emoji_events;
      medalColor = Colors.grey;
    } else if (showMedal && rank == 3) {
      medalIcon = Icons.emoji_events;
      medalColor = Colors.brown[400];
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              showMedal
                  ? gradeColor.withValues(alpha: 0.3)
                  : (isDarkMode
                      ? const Color(0xFF30363D)
                      : Colors.grey.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  showMedal
                      ? LinearGradient(
                        colors: [
                          medalColor!,
                          medalColor.withValues(alpha: 0.8),
                        ],
                      )
                      : null,
              color:
                  showMedal
                      ? null
                      : AppColors.primaryColor.withValues(alpha: 0.1),
            ),
            child: Center(
              child:
                  medalIcon != null
                      ? Icon(medalIcon, color: Colors.white, size: 24.r)
                      : Text(
                        '#$rank',
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
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
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
                        color:
                            isDarkMode
                                ? const Color(0xFF21262D)
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        student.currentLevel,
                        style: AppTextStyles.cairo10w400.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${student.getCompletedAssessmentsCount()} اختبارات',
                      style: AppTextStyles.cairo10w400.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
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
