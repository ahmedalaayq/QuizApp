import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/features/home/widgets/home_app_bar.dart';
import 'package:quiz_app/core/features/home/widgets/home_assessment_card.dart';
import 'package:quiz_app/core/features/home/widgets/home_features_section.dart';
import 'package:quiz_app/core/features/home/widgets/home_section_title.dart';
import 'package:quiz_app/core/features/home/widgets/home_welcome_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeWelcomeCard(),
            SizedBox(height: 24.h),

          
            _buildQuickActions(),
            SizedBox(height: 32.h),

            const HomeSectionTitle(title: 'الاختبارات المتاحة'),
            SizedBox(height: 16.h),

            HomeAssessmentCard(
              title: 'مقياس الاكتئاب والقلق والإجهاد',
              subtitle: 'DASS-21',
              description: 'قياس مستويات الاكتئاب والقلق والإجهاد لديك',
              icon: '😔',
              color: AppColors.goodColor,
              questions: '21 سؤال',
              onTap: () => Get.toNamed('/assessments-list'),
            ),
            SizedBox(height: 16.h),

            HomeAssessmentCard(
              title: 'مقياس التوحد',
              subtitle: 'Autism Spectrum Screening',
              description: 'تقييم خصائص طيف التوحد والتواصل الاجتماعي',
              icon: '🧠',
              color: AppColors.warningColor,
              questions: '10 أسئلة',
              onTap: () => Get.toNamed('/assessments-list'),
            ),
            SizedBox(height: 32.h),

            const HomeFeaturesSection(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.bar_chart,
            title: 'الإحصائيات',
            color: Colors.blue,
            onTap: () => Get.toNamed('/statistics'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.emoji_events,
            title: 'الإنجازات',
            color: Colors.amber,
            onTap: () => Get.toNamed('/achievements'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.settings,
            title: 'الإعدادات',
            color: Colors.grey,
            onTap: () => Get.toNamed('/settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.r),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.cairo12w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
