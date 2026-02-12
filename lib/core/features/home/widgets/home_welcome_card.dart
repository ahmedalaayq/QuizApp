import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class HomeWelcomeCard extends StatelessWidget {
  const HomeWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder:
          (context, scale, child) => Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Opacity(opacity: scale, child: child),
          ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryDark,
              AppColors.whiteColor.withValues(alpha: 0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك',
              style: AppTextStyles.cairo24w700.copyWith(
                color: AppColors.whiteColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'تقييمات مختصرة + تقارير قابلة للطباعة لمساعدتك في متابعة الحالة بوضوح.',
              style: AppTextStyles.cairo14w400.copyWith(
                color: AppColors.whiteColor.withValues(alpha: 0.96),
                height: 1.65,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _Pill(icon: Icons.shield_outlined, label: 'خصوصية'),
                SizedBox(width: 10.w),
                _Pill(icon: Icons.description_outlined, label: 'تقارير'),
                SizedBox(width: 10.w),
                _Pill(icon: Icons.insights_outlined, label: 'تحليلات'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.r,
            color: AppColors.whiteColor.withValues(alpha: 0.95),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.cairo12w600.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
