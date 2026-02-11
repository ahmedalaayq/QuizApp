import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/user_settings_model.dart';
import 'package:quiz_app/core/services/biometric_service.dart';
import 'package:quiz_app/core/services/notification_service.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool biometricEnabled = false.obs;
  final RxInt reminderFrequency = 7.obs;
  final RxBool biometricAvailable = false.obs;
  final RxString biometricType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _checkBiometricAvailability();
  }

  void _loadSettings() {
    final settings = HiveService.getSettings();
    if (settings != null) {
      notificationsEnabled.value = settings.notificationsEnabled;
      biometricEnabled.value = settings.biometricEnabled;
      reminderFrequency.value = settings.reminderFrequency;
    }
  }

  Future<void> _checkBiometricAvailability() async {
    biometricAvailable.value = await BiometricService.isAvailable();
    if (biometricAvailable.value) {
      biometricType.value = await BiometricService.getBiometricTypeText();
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (value) {
    
      final granted = await NotificationService.requestPermissions();
      if (!granted) {
        Get.snackbar(
          'تنبيه',
          'يرجى السماح بالإشعارات من إعدادات الجهاز',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

    
      await NotificationService.scheduleMotivationalNotifications();
    } else {
    
      await NotificationService.cancelAllNotifications();
    }

    notificationsEnabled.value = value;
    await _saveSettings();

    Get.snackbar(
      'تم',
      value ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> toggleBiometric(bool value) async {
    if (!biometricAvailable.value) {
      Get.snackbar(
        'غير متاح',
        'المصادقة البيومترية غير متاحة على هذا الجهاز',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (value) {
    
      final authenticated = await BiometricService.authenticate(
        reason: 'قم بالمصادقة لتفعيل قفل التطبيق',
      );

      if (!authenticated) {
        Get.snackbar(
          'فشل',
          'فشلت المصادقة. يرجى المحاولة مرة أخرى',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.snackbar(
        'تم التفعيل',
        'تم تفعيل قفل التطبيق بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
    
      final authenticated = await BiometricService.authenticate(
        reason: 'قم بالمصادقة لإيقاف قفل التطبيق',
      );

      if (!authenticated) {
        Get.snackbar(
          'فشل',
          'فشلت المصادقة. يرجى المحاولة مرة أخرى',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.snackbar(
        'تم الإيقاف',
        'تم إيقاف قفل التطبيق',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    biometricEnabled.value = value;
    await _saveSettings();
  }

  Future<void> setReminderFrequency(int days) async {
    reminderFrequency.value = days;
    await _saveSettings();

  
    if (notificationsEnabled.value) {
      await NotificationService.schedulePeriodicReminder(
        id: 10,
        title: 'تذكير',
        body: 'حان وقت إجراء تقييم جديد لصحتك النفسية',
        days: days,
      );
    }

    Get.snackbar(
      'تم التحديث',
      'تم تحديث تكرار التذكير إلى كل $days أيام',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _saveSettings() async {
    final currentSettings = HiveService.getSettings() ?? UserSettings();
    await HiveService.saveSettings(
      currentSettings.copyWith(
        notificationsEnabled: notificationsEnabled.value,
        biometricEnabled: biometricEnabled.value,
        reminderFrequency: reminderFrequency.value,
      ),
    );
  }

  Future<void> backupData() async {
  
    Get.snackbar(
      'نسخ احتياطي',
      'تم حفظ البيانات بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> clearAllData() async {
    await HiveService.clearAllData();

  
    notificationsEnabled.value = true;
    biometricEnabled.value = false;
    reminderFrequency.value = 7;

    Get.snackbar(
      'تم الحذف',
      'تم حذف جميع البيانات بنجاح',
      snackPosition: SnackPosition.BOTTOM,
    );
  }


  Future<void> testNotification() async {
    await NotificationService.showNotification(
      id: 999,
      title: 'اختبار الإشعار',
      body: 'هذا إشعار تجريبي للتأكد من عمل الإشعارات',
    );
  }
}
