import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class HomeAssessmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String questions;
  final VoidCallback onTap;

  const HomeAssessmentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.questions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                      : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color:
                  isDarkMode
                      ? color.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.18),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color:
                    isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.10),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, size: 36.r, color: color)),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cairo16w700.copyWith(
                        color:
                            isDarkMode
                                ? const Color(0xFFF7FAFC)
                                : AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.cairo12w600.copyWith(color: color),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cairo12w400.copyWith(
                        color:
                            isDarkMode
                                ? const Color(0xFFA0AEC0)
                                : AppColors.greyDarkColor,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7.r),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            questions,
                            style: AppTextStyles.cairo11w600.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? const Color(0xFF4A5568)
                                    : AppColors.greyLightColor,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Text(
                            'يستغرق 3–6 دقائق',
                            style: AppTextStyles.cairo11w600.copyWith(
                              color:
                                  isDarkMode
                                      ? const Color(0xFFA0AEC0)
                                      : AppColors.greyDarkColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.arrow_forward_ios,
                color:
                    isDarkMode
                        ? const Color(0xFFA0AEC0)
                        : AppColors.greyMediumColor,
                size: 18.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
