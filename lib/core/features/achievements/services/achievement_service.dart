import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/features/achievements/models/achievement_model.dart';

class AchievementService {
  // التحقق من الإنجازات بعد إكمال اختبار
  static Future<List<Achievement>> checkAchievements() async {
    final unlockedAchievements = <Achievement>[];
    final allAchievements = Achievement.getAllAchievements();
    final assessments = HiveService.getAllResults();

    for (var achievement in allAchievements) {
      // تخطي الإنجازات المفتوحة مسبقاً
      if (HiveService.isAchievementUnlocked(achievement.id)) {
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.category) {
        case 'assessments':
          shouldUnlock = assessments.length >= achievement.requiredCount;
          break;

        case 'variety':
          final types = assessments.map((a) => a.assessmentType).toSet();
          shouldUnlock = types.length >= achievement.requiredCount;
          break;

        case 'progress':
          shouldUnlock = _checkImprovement(assessments);
          break;

        case 'streak':
          shouldUnlock = _checkStreak(assessments, achievement.requiredCount);
          break;

        default:
          break;
      }

      if (shouldUnlock) {
        await HiveService.unlockAchievement(achievement.id);
        unlockedAchievements.add(achievement);
      }
    }

    return unlockedAchievements;
  }

  // التحقق من التحسن
  static bool _checkImprovement(List assessments) {
    if (assessments.length < 2) return false;

    final sorted = List.from(assessments)
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    final first = sorted.first.totalScore;
    final last = sorted.last.totalScore;

    return last < first; // النتيجة الأقل تعني تحسن في الحالة النفسية
  }

  // التحقق من الاستمرارية
  static bool _checkStreak(List assessments, int requiredDays) {
    if (assessments.length < requiredDays) return false;

    final sorted = List.from(assessments)
      ..sort((a, b) => b.completionDate.compareTo(a.completionDate));

    int streak = 1;
    for (int i = 0; i < sorted.length - 1; i++) {
      final diff =
          sorted[i].completionDate
              .difference(sorted[i + 1].completionDate)
              .inDays;
      if (diff == 1) {
        streak++;
        if (streak >= requiredDays) return true;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    return false;
  }

  // عرض إشعار الإنجاز
  static void showAchievementNotification(Achievement achievement) {
    Get.snackbar(
      '🎉 إنجاز جديد!',
      '${achievement.icon} ${achievement.title}\n${achievement.description}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  // الحصول على نسبة الإنجازات
  static double getAchievementProgress() {
    final allAchievements = Achievement.getAllAchievements();
    final unlockedCount =
        allAchievements
            .where((a) => HiveService.isAchievementUnlocked(a.id))
            .length;
    return unlockedCount / allAchievements.length;
  }

  // الحصول على عدد الإنجازات المفتوحة
  static int getUnlockedCount() {
    final allAchievements = Achievement.getAllAchievements();
    return allAchievements
        .where((a) => HiveService.isAchievementUnlocked(a.id))
        .length;
  }
}
