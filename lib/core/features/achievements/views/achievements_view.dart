import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/achievements/controller/achievements_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AchievementsController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('الإنجازات ولوحة الشرف'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: isDarkMode ? const Color(0xFF161B22) : Colors.white,
              child: TabBar(
                labelColor: AppColors.primaryColor,
                unselectedLabelColor:
                    isDarkMode ? Colors.grey[400] : Colors.grey[600],
                indicatorColor: AppColors.primaryColor,
                tabs: [
                  Tab(icon: Icon(Icons.emoji_events), text: 'إنجازاتي'),
                  Tab(icon: Icon(Icons.leaderboard), text: 'لوحة الشرف'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAchievementsTab(controller, isDarkMode),
                  _buildLeaderboardTab(controller, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab(
    AchievementsController controller,
    bool isDarkMode,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Overview
            _buildProgressOverview(controller, isDarkMode),

            SizedBox(height: 24.h),

            // Achievements Grid
            Text(
              'الإنجازات المحققة',
              style: AppTextStyles.cairo18w700.copyWith(
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 16.h),

            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.1,
              ),
              itemCount: controller.achievements.length,
              itemBuilder: (context, index) {
                final achievement = controller.achievements[index];
                return _buildAchievementCard(achievement, isDarkMode);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLeaderboardTab(
    AchievementsController controller,
    bool isDarkMode,
  ) {
    return Obx(() {
      if (controller.isLoadingLeaderboard.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 3 Podium
            _buildTopThreePodium(controller, isDarkMode),

            SizedBox(height: 32.h),

            // Full Leaderboard
            Text(
              'التصنيف العام',
              style: AppTextStyles.cairo18w700.copyWith(
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 16.h),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.leaderboard.length,
              itemBuilder: (context, index) {
                final student = controller.leaderboard[index];
                return _buildLeaderboardTile(student, index + 1, isDarkMode);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProgressOverview(
    AchievementsController controller,
    bool isDarkMode,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF1E2A3A), const Color(0xFF2D3748)]
                  : [
                    AppColors.primaryColor.withValues(alpha: 0.05),
                    AppColors.primaryColor.withValues(alpha: 0.1),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isDarkMode
                  ? const Color(0xFF4A5568)
                  : AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: AppColors.primaryColor,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي الإنجازات',
                      style: AppTextStyles.cairo14w500.copyWith(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${controller.unlockedAchievements.value} من ${controller.achievements.length}',
                      style: AppTextStyles.cairo20w700.copyWith(
                        color:
                            isDarkMode ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedProgressBar(
            progress: controller.achievementProgress.value,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            progressColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    Map<String, dynamic> achievement,
    bool isDarkMode,
  ) {
    final isUnlocked = achievement['isUnlocked'] ?? false;

    return AnimatedCard(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isUnlocked
                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                    : (isDarkMode
                        ? const Color(0xFF30363D)
                        : Colors.grey.withValues(alpha: 0.2)),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isUnlocked
                      ? AppColors.primaryColor.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color:
                    isUnlocked
                        ? AppColors.primaryColor.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAchievementIcon(achievement['type']),
                color: isUnlocked ? AppColors.primaryColor : Colors.grey,
                size: 24.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              achievement['title'] ?? '',
              style: AppTextStyles.cairo12w600.copyWith(
                color:
                    isUnlocked
                        ? (isDarkMode ? Colors.white : AppColors.primaryDark)
                        : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              achievement['description'] ?? '',
              style: AppTextStyles.cairo10w400.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'مُحقق',
                  style: AppTextStyles.cairo10w600.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreePodium(
    AchievementsController controller,
    bool isDarkMode,
  ) {
    if (controller.leaderboard.length < 3) {
      return Container(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: Text(
            'لا يوجد عدد كافٍ من الطلاب لعرض المنصة',
            style: AppTextStyles.cairo14w500.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    final first = controller.leaderboard[0];
    final second = controller.leaderboard[1];
    final third = controller.leaderboard[2];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                  : [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: isDarkMode ? Colors.amber : AppColors.primaryDark,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'أفضل ثلاثة طلاب',
                style: AppTextStyles.cairo18w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.emoji_events,
                color: isDarkMode ? Colors.amber : AppColors.primaryDark,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second Place
              _buildPodiumPlace(second, 2, 80.h, Colors.grey, isDarkMode),
              // First Place
              _buildPodiumPlace(first, 1, 100.h, Colors.amber, isDarkMode),
              // Third Place
              _buildPodiumPlace(third, 3, 60.h, Colors.brown, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    Map<String, dynamic> student,
    int place,
    double height,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              place == 1
                  ? Icons.workspace_premium
                  : place == 2
                  ? Icons.military_tech
                  : Icons.emoji_events,
              color:
                  place == 1
                      ? Colors.amber
                      : place == 2
                      ? Colors.grey[400]
                      : Colors.brown[400],
              size: 24.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          student['name'] ?? 'مجهول',
          style: AppTextStyles.cairo12w600.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          '${student['totalScore'] ?? 0} نقطة',
          style: AppTextStyles.cairo14w500.copyWith(color: color),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 60.w,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
          ),
          child: Center(
            child: Text(
              '#$place',
              style: AppTextStyles.cairo16w700.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
    Map<String, dynamic> student,
    int rank,
    bool isDarkMode,
  ) {
    Color rankColor = Colors.grey;
    if (rank == 1)
      rankColor = Colors.amber;
    else if (rank == 2)
      rankColor = Colors.grey[400]!;
    else if (rank == 3)
      rankColor = Colors.brown;

    return AnimatedCard(
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                rank <= 3
                    ? rankColor.withValues(alpha: 0.3)
                    : (isDarkMode
                        ? const Color(0xFF30363D)
                        : Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: AppTextStyles.cairo12w700.copyWith(color: rankColor),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] ?? 'مجهول',
                    style: AppTextStyles.cairo14w600.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '${student['completedAssessments'] ?? 0} تقييم مكتمل',
                    style: AppTextStyles.cairo12w400.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student['totalScore'] ?? 0}',
                  style: AppTextStyles.cairo16w700.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  'نقطة',
                  style: AppTextStyles.cairo14w500.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String? type) {
    switch (type) {
      case 'first_assessment':
        return Icons.play_arrow;
      case 'streak':
        return Icons.local_fire_department;
      case 'perfectionist':
        return Icons.star;
      case 'explorer':
        return Icons.explore;
      case 'consistent':
        return Icons.schedule;
      case 'improver':
        return Icons.trending_up;
      case 'social':
        return Icons.share;
      case 'dedicated':
        return Icons.favorite;
      default:
        return Icons.emoji_events;
    }
  }
}
