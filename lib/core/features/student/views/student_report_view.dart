import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/student_rating_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentReportView extends StatefulWidget {
  final StudentProfile student;

  const StudentReportView({super.key, required this.student});

  @override
  State<StudentReportView> createState() => _StudentReportViewState();
}

class _StudentReportViewState extends State<StudentReportView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = StudentRatingService.generateStudentReport(widget.student);
    final grade = StudentRatingService.calculateStudentGrade(report.statistics);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'التقرير الشامل',
          style: AppTextStyles.cairo18w600.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'النظرة العامة', icon: Icon(Icons.dashboard, size: 20.r)),
            Tab(text: 'التحليل', icon: Icon(Icons.analytics, size: 20.r)),
            Tab(text: 'التوصيات', icon: Icon(Icons.lightbulb, size: 20.r)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(report, grade),
          _buildAnalyticsTab(report),
          _buildRecommendationsTab(report),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(StudentReport report, double grade) {
    final classification = StudentRatingService.classifyStudent(
      report.statistics,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            backgroundColor: AppColors.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'الدرجة الإجمالية',
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: AppColors.whiteColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.whiteColor.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      grade.toStringAsFixed(1),
                      style: AppTextStyles.cairo24w700.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  classification,
                  style: AppTextStyles.cairo16w600.copyWith(
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          Text('الإحصائيات الأساسية', style: AppTextStyles.cairo16w700),
          SizedBox(height: 12.h),
          _buildStatisticsGrid(report.statistics),
          SizedBox(height: 20.h),

          if (report.statistics.severityDistribution.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('توزيع مستويات الشدة', style: AppTextStyles.cairo16w700),
                SizedBox(height: 12.h),
                ...report.statistics.severityDistribution.entries.map((entry) {
                  final severity = entry.key;
                  final count = entry.value;
                  final percentage =
                      (count / report.statistics.totalAssessmentsTaken) * 100;

                  Color severityColor = Colors.grey;
                  if (severity == 'طبيعي') {
                    severityColor = Colors.green;
                  } else if (severity == 'خفيف') {
                    severityColor = Colors.yellow[700]!;
                  } else if (severity == 'متوسط') {
                    severityColor = Colors.orange;
                  } else if (severity == 'شديد') {
                    severityColor = Colors.red;
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(severity, style: AppTextStyles.cairo12w600),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: AppTextStyles.cairo12w600.copyWith(
                                color: severityColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8.h,
                            backgroundColor: severityColor.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation(severityColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          SizedBox(height: 20.h),

          CustomCard(
            backgroundColor: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      'معلومات إضافية',
                      style: AppTextStyles.cairo14w600.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildInfoItem(
                  'عدد الاختبارات المكتملة',
                  '${report.statistics.totalAssessmentsTaken}',
                ),
                _buildInfoItem(
                  'متوسط الوقت لكل اختبار',
                  '${(report.statistics.averageTimePerAssessment.inSeconds ~/ 60).toString()} دقيقة',
                ),
                _buildInfoItem(
                  'أفضل درجة',
                  (report.recentAssessments.isNotEmpty
                      ? report.recentAssessments
                          .fold<double>(
                            0,
                            (max, a) =>
                                a.getPercentageScore() > max
                                    ? a.getPercentageScore()
                                    : max,
                          )
                          .toStringAsFixed(0)
                      : '0'),
                ),
                _buildInfoItem(
                  'أقل درجة',
                  (report.recentAssessments.isNotEmpty
                      ? report.recentAssessments
                          .fold<double>(
                            100,
                            (min, a) =>
                                a.getPercentageScore() < min
                                    ? a.getPercentageScore()
                                    : min,
                          )
                          .toStringAsFixed(0)
                      : '0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(Statistics statistics) {
    return GridView.count(
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
          AppColors.primaryColor,
        ),
        _buildStatCard(
          'الدقة',
          '${statistics.averageAccuracy.toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'التقدم',
          '${statistics.progressPercentage.toStringAsFixed(0)}%',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'الاختبارات',
          '${statistics.totalAssessmentsTaken}',
          Icons.assignment,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28.r),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cairo12w400,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: AppTextStyles.cairo16w700.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.cairo12w400),
          Text(value, style: AppTextStyles.cairo12w600),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(StudentReport report) {
    final performancePattern = StudentRatingService.analyzePerformancePattern(
      widget.student,
    );
    final trend = performancePattern['trend'];
    final improvement = performancePattern['improvement'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            backgroundColor: _getTrendColor(trend).withOpacity(0.1),
            border: Border.all(color: _getTrendColor(trend), width: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  _getTrendIcon(trend),
                  color: _getTrendColor(trend),
                  size: 40.r,
                ),
                SizedBox(height: 12.h),
                Text('اتجاه الأداء', style: AppTextStyles.cairo14w600),
                SizedBox(height: 8.h),
                Text(
                  trend,
                  style: AppTextStyles.cairo16w700.copyWith(
                    color: _getTrendColor(trend),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'تحسن بنسبة ${improvement.toStringAsFixed(1)}%',
                  style: AppTextStyles.cairo12w400,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          if (report.statistics.categoryPerformance.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أداء الفئات', style: AppTextStyles.cairo16w700),
                SizedBox(height: 12.h),
                ...report.statistics.categoryPerformance.entries.map((entry) {
                  final category = entry.key;
                  final performance = entry.value;
                  final percentage = (performance * 100);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(category, style: AppTextStyles.cairo12w600),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: AppTextStyles.cairo12w600,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        CustomProgressBar(
                          value: performance,
                          valueColor: Colors.blue,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(StudentReport report) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.recommendations.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60.r),
                    SizedBox(height: 16.h),
                    Text(
                      'أداء ممتاز!',
                      style: AppTextStyles.cairo18w700.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'لا توجد توصيات - استمر في التقدم',
                      style: AppTextStyles.cairo14w400.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...report.recommendations.map((rec) {
              Color categoryColor = Colors.grey;
              IconData categoryIcon = Icons.lightbulb;

              if (rec.category == 'improvement') {
                categoryColor = Colors.orange;
                categoryIcon = Icons.trending_up;
              } else if (rec.category == 'intervention') {
                categoryColor = Colors.red;
                categoryIcon = Icons.warning;
              } else {
                categoryColor = Colors.blue;
                categoryIcon = Icons.info;
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: CustomCard(
                  backgroundColor: categoryColor.withOpacity(0.05),
                  border: Border.all(color: categoryColor, width: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(categoryIcon, color: categoryColor, size: 24.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.title,
                                  style: AppTextStyles.cairo14w600.copyWith(
                                    color: categoryColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'الأولوية: ${rec.priority}',
                                  style: AppTextStyles.cairo11w400.copyWith(
                                    color: categoryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(rec.description, style: AppTextStyles.cairo12w400),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend == 'متحسّن') return Colors.green;
    if (trend == 'متراجع') return Colors.red;
    return Colors.blue;
  }

  IconData _getTrendIcon(String trend) {
    if (trend == 'متحسّن') return Icons.trending_up;
    if (trend == 'متراجع') return Icons.trending_down;
    return Icons.trending_flat;
  }
}
