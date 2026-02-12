import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/features/home/widgets/home_section_title.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class HomeFeaturesSection extends StatelessWidget {
  const HomeFeaturesSection({super.key});

  int _crossAxisCount(double width) {
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = _crossAxisCount(width);

    final features = const <_FeatureData>[
      _FeatureData(
        icon: Icons.analytics_outlined,
        title: 'ملخص واضح للنتائج',
        description: 'بنطلع لك أهم المؤشرات بشكل مفهوم مع نسبة وتفسير مبسط.',
        tint: AppColors.secondaryColor,
      ),
      _FeatureData(
        icon: Icons.description_outlined,
        title: 'تقرير قابل للطباعة',
        description: 'تقدر تحفظ التقرير PDF أو تشاركه مع المختص بسهولة.',
        tint: AppColors.primaryColor,
      ),
      _FeatureData(
        icon: Icons.lock_outline,
        title: 'خصوصية وبيانات آمنة',
        description: 'بياناتك بتتخزن بشكل آمن، وتقدر تمسحها وقت ما تحب.',
        tint: AppColors.goodColor,
      ),
      _FeatureData(
        icon: Icons.tips_and_updates_outlined,
        title: 'توصيات عملية بعد الاختبار',
        description: 'خطوات بسيطة تساعدك تبدأ صح قبل زيارة المختص.',
        tint: AppColors.warningColor,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: 'المميزات'),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: crossAxisCount == 1 ? 3.2 : 2.4,
          ),
          itemBuilder: (context, index) {
            final f = features[index];
            return _FeatureCard(data: f);
          },
        ),
      ],
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color tint;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.tint,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder:
          (context, t, child) => Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: Opacity(opacity: t, child: child),
          ),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color:
                isDarkMode
                    ? data.tint.withValues(alpha: 0.3)
                    : data.tint.withValues(alpha: 0.14),
          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    data.tint.withValues(alpha: 0.15),
                    data.tint.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: data.tint.withValues(alpha: 0.2)),
              ),
              child: Icon(data.icon, color: data.tint, size: 24.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.cairo14w700.copyWith(
                      color:
                          isDarkMode
                              ? const Color(0xFFF7FAFC)
                              : AppColors.primaryDark,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    data.description,
                    style: AppTextStyles.cairo12w400.copyWith(
                      color:
                          isDarkMode
                              ? const Color(0xFFA0AEC0)
                              : AppColors.greyDarkColor,
                      height: 1.55,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
