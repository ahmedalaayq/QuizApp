import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {}

  static Future<bool> requestPermissions() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    bool? androidGranted;
    bool? iosGranted;

    if (androidPlugin != null) {
      androidGranted = await androidPlugin.requestNotificationsPermission();
    }

    if (iosPlugin != null) {
      iosGranted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return androidGranted ?? iosGranted ?? false;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'assessment_channel',
      'تذكيرات الاختبارات',
      channelDescription: 'إشعارات تذكير بإجراء الاختبارات النفسية',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'assessment_channel',
      'تذكيرات الاختبارات',
      channelDescription: 'إشعارات تذكير بإجراء الاختبارات النفسية',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> schedulePeriodicReminder({
    required int id,
    required String title,
    required String body,
    required int days,
  }) async {
    await cancelNotification(id);

    final nextDate = DateTime.now().add(Duration(days: days));
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextDate,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> scheduleMotivationalNotifications() async {
    final messages = [
      'حان وقت الاهتمام بصحتك النفسية!',
      'تذكر: صحتك النفسية أولوية',
      'خذ دقائق لتقييم حالتك النفسية اليوم',
      'الاهتمام بنفسك ليس رفاهية، بل ضرورة',
      'كيف حالك اليوم؟ دعنا نتحقق معاً',
    ];

    for (int i = 0; i < messages.length; i++) {
      final date = DateTime.now().add(Duration(days: (i + 1) * 3));
      await scheduleNotification(
        id: 100 + i,
        title: 'منصة التقييم النفسي',
        body: messages[i],
        scheduledDate: date,
      );
    }
  }

  static Future<void> showCompletionNotification(String assessmentTitle) async {
    await showNotification(
      id: 1,
      title: '✅ تم إكمال الاختبار',
      body: 'تم حفظ نتائج $assessmentTitle بنجاح',
    );
  }

  static Future<void> showAchievementNotification(
    String achievementTitle,
    String achievementIcon,
  ) async {
    await showNotification(
      id: 2,
      title: 'إنجاز جديد!',
      body: '$achievementIcon $achievementTitle',
    );
  }
}
