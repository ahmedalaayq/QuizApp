import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';

class AchievementsController extends GetxController {
  var isLoading = false.obs;
  var isLoadingLeaderboard = false.obs;
  var achievements = <Map<String, dynamic>>[].obs;
  var leaderboard = <Map<String, dynamic>>[].obs;
  var unlockedAchievements = 0.obs;
  var achievementProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
    loadLeaderboard();
  }

  Future<void> loadAchievements() async {
    try {
      isLoading.value = true;

      // Load default achievements
      achievements.value = [
        {
          'id': 'first_assessment',
          'title': 'البداية',
          'description': 'أكمل أول تقييم نفسي',
          'type': 'first_assessment',
          'isUnlocked': await _checkFirstAssessment(),
        },
        {
          'id': 'streak_3',
          'title': 'المثابر',
          'description': 'أكمل 3 تقييمات متتالية',
          'type': 'streak',
          'isUnlocked': await _checkStreak(3),
        },
        {
          'id': 'perfectionist',
          'title': 'المتقن',
          'description': 'احصل على نتيجة ممتازة',
          'type': 'perfectionist',
          'isUnlocked': await _checkPerfectionist(),
        },
        {
          'id': 'explorer',
          'title': 'المستكشف',
          'description': 'جرب جميع أنواع التقييمات',
          'type': 'explorer',
          'isUnlocked': await _checkExplorer(),
        },
        {
          'id': 'consistent',
          'title': 'المنتظم',
          'description': 'أكمل تقييم كل أسبوع لمدة شهر',
          'type': 'consistent',
          'isUnlocked': await _checkConsistent(),
        },
        {
          'id': 'improver',
          'title': 'المتطور',
          'description': 'حسن نتائجك عبر الوقت',
          'type': 'improver',
          'isUnlocked': await _checkImprover(),
        },
        {
          'id': 'social',
          'title': 'الاجتماعي',
          'description': 'شارك نتائجك مع الآخرين',
          'type': 'social',
          'isUnlocked': await _checkSocial(),
        },
        {
          'id': 'dedicated',
          'title': 'المخلص',
          'description': 'استخدم التطبيق لمدة 30 يوم',
          'type': 'dedicated',
          'isUnlocked': await _checkDedicated(),
        },
      ];

      _updateProgress();
    } catch (e) {
      // Handle error silently or use proper logging
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      isLoadingLeaderboard.value = true;

      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isConnected.value) {
        // Load from Firebase
        final firebaseLeaderboard = await FirebaseService.getLeaderboard();
        leaderboard.value = firebaseLeaderboard;
      } else {
        // Load mock data for offline
        leaderboard.value = _getMockLeaderboard();
      }

      // Sort by total score
      leaderboard.sort(
        (a, b) => (b['totalScore'] ?? 0).compareTo(a['totalScore'] ?? 0),
      );
    } catch (e) {
      // Handle error silently or use proper logging
      leaderboard.value = _getMockLeaderboard();
    } finally {
      isLoadingLeaderboard.value = false;
    }
  }

  void _updateProgress() {
    unlockedAchievements.value =
        achievements.where((a) => a['isUnlocked'] == true).length;
    achievementProgress.value =
        achievements.isEmpty
            ? 0.0
            : unlockedAchievements.value / achievements.length;
  }

  Future<bool> _checkFirstAssessment() async {
    final history = HiveService.getAllResults();
    return history.isNotEmpty;
  }

  Future<bool> _checkStreak(int requiredStreak) async {
    final history = HiveService.getAllResults();
    if (history.length < requiredStreak) return false;

    // Check for consecutive assessments
    history.sort((a, b) => b.completionDate.compareTo(a.completionDate));

    int currentStreak = 1;
    for (int i = 1; i < history.length && i < requiredStreak; i++) {
      final daysDiff =
          history[i - 1].completionDate
              .difference(history[i].completionDate)
              .inDays;
      if (daysDiff <= 7) {
        // Within a week
        currentStreak++;
      } else {
        break;
      }
    }

    return currentStreak >= requiredStreak;
  }

  Future<bool> _checkPerfectionist() async {
    final history = HiveService.getAllResults();
    return history.any(
      (h) => h.overallSeverity == 'ممتاز' || h.totalScore >= 80,
    );
  }

  Future<bool> _checkExplorer() async {
    final history = HiveService.getAllResults();
    final types = history.map((h) => h.assessmentType).toSet();
    return types.length >= 2; // At least 2 different types
  }

  Future<bool> _checkConsistent() async {
    final history = HiveService.getAllResults();
    if (history.length < 4) return false;

    // Check for weekly assessments over a month
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final recentHistory =
        history.where((h) => h.completionDate.isAfter(monthAgo)).toList();

    // Group by week
    final weeklyAssessments = <int, int>{};
    for (final assessment in recentHistory) {
      final weekNumber =
          assessment.completionDate.difference(monthAgo).inDays ~/ 7;
      weeklyAssessments[weekNumber] = (weeklyAssessments[weekNumber] ?? 0) + 1;
    }

    return weeklyAssessments.length >= 4; // At least 4 weeks with assessments
  }

  Future<bool> _checkImprover() async {
    final history = HiveService.getAllResults();
    if (history.length < 3) return false;

    history.sort((a, b) => a.completionDate.compareTo(b.completionDate));

    // Check if scores are generally improving
    final firstThird =
        history
            .take(history.length ~/ 3)
            .map((h) => h.totalScore)
            .reduce((a, b) => a + b) /
        (history.length ~/ 3);
    final lastThird =
        history
            .skip(history.length * 2 ~/ 3)
            .map((h) => h.totalScore)
            .reduce((a, b) => a + b) /
        (history.length - history.length * 2 ~/ 3);

    return lastThird > firstThird + 10; // Improved by at least 10 points
  }

  Future<bool> _checkSocial() async {
    // This would be implemented based on sharing functionality
    // For now, return false as sharing is not implemented
    return false;
  }

  Future<bool> _checkDedicated() async {
    final settings = HiveService.getSettings();
    if (settings == null) return false;

    // This would check app usage over 30 days
    // For now, return false as usage tracking is not fully implemented
    return false;
  }

  List<Map<String, dynamic>> _getMockLeaderboard() {
    return [
      {
        'name': 'أحمد عماد',
        'totalScore': 95,
        'completedAssessments': 12,
        'rank': 1,
      },
      {
        'name': "سارة كمال",
        'totalScore': 88,
        'completedAssessments': 10,
        'rank': 2,
      },
      {
        'name': 'كريم عبدالشهيد',
        'totalScore': 82,
        'completedAssessments': 9,
        'rank': 3,
      },
      {
        'name': 'معاذ صلاح',
        'totalScore': 78,
        'completedAssessments': 8,
        'rank': 4,
      },
    ];
  }

  Future<void> refreshData() async {
    await Future.wait([loadAchievements(), loadLeaderboard()]);
  }
}
