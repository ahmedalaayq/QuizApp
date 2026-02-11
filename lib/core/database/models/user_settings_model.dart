import 'package:hive/hive.dart';

part 'user_settings_model.g.dart';

@HiveType(typeId: 1)
class UserSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String language;

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final bool soundEnabled;

  @HiveField(4)
  final String userName;

  @HiveField(5)
  final int reminderFrequency;

  @HiveField(6)
  final bool biometricEnabled;

  @HiveField(7)
  final DateTime? lastAssessmentDate;

  UserSettings({
    this.isDarkMode = false,
    this.language = 'ar',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.userName = '',
    this.reminderFrequency = 7,
    this.biometricEnabled = false,
    this.lastAssessmentDate,
  });

  UserSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? userName,
    int? reminderFrequency,
    bool? biometricEnabled,
    DateTime? lastAssessmentDate,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      userName: userName ?? this.userName,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'ar',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      userName: json['userName'] as String? ?? '',
      reminderFrequency: json['reminderFrequency'] as int? ?? 7,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      lastAssessmentDate:
          json['lastAssessmentDate'] != null
              ? DateTime.parse(json['lastAssessmentDate'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'userName': userName,
      'reminderFrequency': reminderFrequency,
      'biometricEnabled': biometricEnabled,
      'lastAssessmentDate': lastAssessmentDate?.toIso8601String(),
    };
  }
}
