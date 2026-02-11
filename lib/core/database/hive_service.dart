import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/database/models/user_settings_model.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class HiveService {
  static const String assessmentHistoryBox = 'assessment_history';
  static const String userSettingsBox = 'user_settings';
  static const String achievementsBox = 'achievements';

  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AssessmentHistoryAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserSettingsAdapter());
      }

      // Open boxes
      await Hive.openBox<AssessmentHistory>(assessmentHistoryBox);
      await Hive.openBox<UserSettings>(userSettingsBox);
      await Hive.openBox(achievementsBox);

      _isInitialized = true;
      LoggerService.info('HiveService initialized successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Error initializing Hive', e, stackTrace);
      rethrow;
    }
  }

  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'HiveService not initialized. Call HiveService.init() first.',
      );
    }
  }

  static Future<void> saveAssessmentResult(AssessmentHistory history) async {
    _ensureInitialized();
    try {
      final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
      await box.add(history);
      LoggerService.info('Assessment result saved to local storage');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error saving assessment result to local storage',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static List<AssessmentHistory> getAllResults() {
    _ensureInitialized();
    try {
      final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
      return box.values.toList();
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting all results from local storage',
        e,
        stackTrace,
      );
      return [];
    }
  }

  static List<AssessmentHistory> getResultsByType(String type) {
    _ensureInitialized();
    try {
      final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
      return box.values
          .where((result) => result.assessmentType == type)
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting results by type from local storage',
        e,
        stackTrace,
      );
      return [];
    }
  }

  static List<AssessmentHistory> getRecentResults({int limit = 5}) {
    _ensureInitialized();
    try {
      final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
      final results = box.values.toList();
      results.sort((a, b) => b.completionDate.compareTo(a.completionDate));
      return results.take(limit).toList();
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting recent results from local storage',
        e,
        stackTrace,
      );
      return [];
    }
  }

  static Future<void> deleteResult(int index) async {
    _ensureInitialized();
    try {
      final box = Hive.box<AssessmentHistory>(assessmentHistoryBox);
      await box.deleteAt(index);
      LoggerService.info('Assessment result deleted from local storage');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error deleting result from local storage',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> saveSettings(UserSettings settings) async {
    _ensureInitialized();
    try {
      final box = Hive.box<UserSettings>(userSettingsBox);
      await box.put('settings', settings);
      LoggerService.info('User settings saved to local storage');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error saving settings to local storage',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static UserSettings? getSettings() {
    _ensureInitialized();
    try {
      final box = Hive.box<UserSettings>(userSettingsBox);
      return box.get('settings');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting settings from local storage',
        e,
        stackTrace,
      );
      return null;
    }
  }

  static Future<void> unlockAchievement(String achievementId) async {
    _ensureInitialized();
    try {
      final box = Hive.box(achievementsBox);
      await box.put(achievementId, DateTime.now().toIso8601String());
      LoggerService.info('Achievement unlocked: $achievementId');
    } catch (e, stackTrace) {
      LoggerService.error('Error unlocking achievement', e, stackTrace);
      rethrow;
    }
  }

  static bool isAchievementUnlocked(String achievementId) {
    _ensureInitialized();
    try {
      final box = Hive.box(achievementsBox);
      return box.containsKey(achievementId);
    } catch (e, stackTrace) {
      LoggerService.error('Error checking achievement status', e, stackTrace);
      return false;
    }
  }

  static Map<String, String> getAllAchievements() {
    _ensureInitialized();
    try {
      final box = Hive.box(achievementsBox);
      return Map<String, String>.from(box.toMap());
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting achievements from local storage',
        e,
        stackTrace,
      );
      return {};
    }
  }

  static Future<void> clearAllData() async {
    _ensureInitialized();
    try {
      await Hive.box<AssessmentHistory>(assessmentHistoryBox).clear();
      await Hive.box<UserSettings>(userSettingsBox).clear();
      await Hive.box(achievementsBox).clear();
      LoggerService.info('All local data cleared');
    } catch (e, stackTrace) {
      LoggerService.error('Error clearing local data', e, stackTrace);
      rethrow;
    }
  }

  // Generic data storage methods
  static Future<void> saveData(String key, dynamic value) async {
    _ensureInitialized();
    try {
      final box = Hive.box(
        achievementsBox,
      ); // Use achievements box for generic data
      await box.put(key, value);
      LoggerService.info('Data saved with key: $key');
    } catch (e, stackTrace) {
      LoggerService.error('Error saving data', e, stackTrace);
      rethrow;
    }
  }

  static dynamic getData(String key) {
    _ensureInitialized();
    try {
      final box = Hive.box(
        achievementsBox,
      ); // Use achievements box for generic data
      return box.get(key);
    } catch (e, stackTrace) {
      LoggerService.error('Error getting data', e, stackTrace);
      return null;
    }
  }

  static Future<void> deleteData(String key) async {
    _ensureInitialized();
    try {
      final box = Hive.box(
        achievementsBox,
      ); // Use achievements box for generic data
      await box.delete(key);
      LoggerService.info('Data deleted with key: $key');
    } catch (e, stackTrace) {
      LoggerService.error('Error deleting data', e, stackTrace);
      rethrow;
    }
  }

  static bool get isInitialized => _isInitialized;
}
