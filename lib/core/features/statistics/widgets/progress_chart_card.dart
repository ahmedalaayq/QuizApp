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

    return Obx(() {
      if (controller.assessments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تطور النتائج', style: AppTextStyles.cairo18w700),
            SizedBox(height: 20.h),
            SizedBox(
              height: 200.h,
              child: LineChart(_buildChartData(controller.assessments)),
            ),
          ],
        ),
      );
    });
  }

  LineChartData _buildChartData(List assessments) {
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
          return FlLine(color: Colors.grey[300], strokeWidth: 1);
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
                  color: Colors.grey[600],
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
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!),
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
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
