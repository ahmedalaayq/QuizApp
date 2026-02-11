import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class StudentRecommendationsSection extends StatelessWidget {
  final List<Recommendation> recommendations;

  const StudentRecommendationsSection({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التوصيات',
            style: AppTextStyles.cairo16w700,
          ),
          SizedBox(height: 12.h),
          CustomCard(
            backgroundColor: Colors.green[50],
            child: Text(
              'لا توجد توصيات حالياً - أداؤك ممتاز!',
              style: AppTextStyles.cairo14w400.copyWith(
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التوصيات',
          style: AppTextStyles.cairo16w700,
        ),
        SizedBox(height: 12.h),
        ...recommendations.map((rec) {
          final categoryColor = _getCategoryColor(rec.category);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CustomCard(
              backgroundColor: categoryColor.withOpacity(0.05),
              border: Border.all(color: categoryColor, width: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rec.title,
                          style: AppTextStyles.cairo13w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'الأولوية: ${rec.priority}',
                          style: AppTextStyles.cairo10w400.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    rec.description,
                    style: AppTextStyles.cairo12w400,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    if (category == 'improvement') {
      return Colors.orange;
    } else if (category == 'intervention') {
      return Colors.red;
    }
    return Colors.blue;
  }
}
