import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/database/models/user_settings_model.dart';

class HiveService {
  static const String assessmentHistoryBox = 'assessment_history';
  static const String userSettingsBox = 'user_settings';
  static const String achievementsBox = 'achievements';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AssessmentHistoryAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    await Hive.openBox<AssessmentHistory>(assessmentHistoryBox);
    await Hive.openBox<UserSettings>(userSettingsBox);
    await Hive.openBox(achievementsBox);
  }

  static Future<void> saveAssessmentResult(AssessmentHistory history) async {
    final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
    await box.add(history);
  }

  static List<AssessmentHistory> getAllResults() {
    final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
    return box.values.toList();
  }

  static List<AssessmentHistory> getResultsByType(String type) {
    final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
    return box.values.where((result) => result.assessmentType == type).toList();
  }

  static List<AssessmentHistory> getRecentResults({int limit = 5}) {
    final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
    final results = box.values.toList();
    results.sort((a, b) => b.completionDate.compareTo(a.completionDate));
    return results.take(limit).toList();
  }

  static Future<void> deleteResult(int index) async {
    final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
    await box.deleteAt(index);
  }

  static Future<void> saveSettings(UserSettings settings) async {
    final box = Hive.box<UserSettings>(userSettingsBox);
    await box.put('settings', settings);
  }

  static UserSettings? getSettings() {
    final box = Hive.box<UserSettings>(userSettingsBox);
    return box.get('settings');
  }

  static Future<void> unlockAchievement(String achievementId) async {
    final box = Hive.box(achievementsBox);
    await box.put(achievementId, DateTime.now().toIso8601String());
  }

  static bool isAchievementUnlocked(String achievementId) {
    final box = Hive.box(achievementsBox);
    return box.containsKey(achievementId);
  }

  static Map<String, String> getAllAchievements() {
    final box = Hive.box(achievementsBox);
    return Map<String, String>.from(box.toMap());
  }

  static Future<void> clearAllData() async {
    await Hive.box<AssessmentHistory>(assessmentHistoryBox).clear();
    await Hive.box<UserSettings>(userSettingsBox).clear();
    await Hive.box(achievementsBox).clear();
  }
}
