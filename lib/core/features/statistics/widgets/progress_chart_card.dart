import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/statistics/controller/statistics_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class ProgressChartCard extends StatelessWidget {
  const ProgressChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.assessments.isEmpty) {
        return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [Colors.white, Colors.grey.shade50],
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
              color:
                  isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تطور النتائج',
              style: AppTextStyles.cairo18w700.copyWith(
                color:
                    isDarkMode
                        ? const Color(0xFFF7FAFC)
                        : AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 200.h,
              child: LineChart(
                _buildChartData(controller.assessments, isDarkMode),
              ),
            ),
          ],
        ),
      );
    });
  }

  LineChartData _buildChartData(List assessments, bool isDarkMode) {
    final spots = <FlSpot>[];

    for (int i = 0; i < assessments.length && i < 10; i++) {
      spots.add(FlSpot(i.toDouble(), assessments[i].totalScore.toDouble()));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDarkMode ? const Color(0xFF4A5568) : Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt() + 1}',
                style: AppTextStyles.cairo11w400.copyWith(
                  color:
                      isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: AppTextStyles.cairo11w400.copyWith(
                  color:
                      isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: isDarkMode ? const Color(0xFF4A5568) : Colors.grey[300]!,
        ),
      ),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: 0,
      maxY: 60,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryColor,
                strokeWidth: 2,
                strokeColor:
                    isDarkMode ? const Color(0xFF2D3748) : Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
