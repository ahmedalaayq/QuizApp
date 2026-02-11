import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/services/biometric_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AppLockService extends GetxController {
  static AppLockService get instance => Get.find();

  var isLocked = false.obs;
  var isEnabled = false.obs;
  var lastBackgroundTime = DateTime.now();
  final int lockTimeoutSeconds = 30; // Lock after 30 seconds in background

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = HiveService.getSettings();
    isEnabled.value = settings?.biometricEnabled ?? false;
  }

  Future<void> enableAppLock() async {
    final isAvailable = await BiometricService.isAvailable();

    if (!isAvailable) {
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'غير متاح',
        'المصادقة البيومترية غير متاحة على هذا الجهاز',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.orange,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      );
      return;
    }

    final authenticated = await BiometricService.authenticate(
      reason: 'قم بتفعيل قفل التطبيق للحماية الإضافية',
    );

    if (authenticated) {
      isEnabled.value = true;
      await _saveSettings();
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'تم التفعيل',
        'تم تفعيل قفل التطبيق بنجاح',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.green,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      );
    }
  }

  Future<void> disableAppLock() async {
    final authenticated = await BiometricService.authenticate(
      reason: 'قم بالمصادقة لإلغاء تفعيل قفل التطبيق',
    );

    if (authenticated) {
      isEnabled.value = false;
      isLocked.value = false;
      await _saveSettings();
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'تم الإلغاء',
        'تم إلغاء تفعيل قفل التطبيق',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.blue,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      );
    }
  }

  Future<void> _saveSettings() async {
    final currentSettings = HiveService.getSettings();
    if (currentSettings != null) {
      await HiveService.saveSettings(
        currentSettings.copyWith(biometricEnabled: isEnabled.value),
      );
    }
  }

  void onAppPaused() {
    if (isEnabled.value) {
      lastBackgroundTime = DateTime.now();
    }
  }

  void onAppResumed() {
    if (isEnabled.value) {
      final timeDiff = DateTime.now().difference(lastBackgroundTime).inSeconds;
      if (timeDiff >= lockTimeoutSeconds) {
        lockApp();
      }
    }
  }

  void lockApp() {
    if (isEnabled.value) {
      isLocked.value = true;
      _showLockScreen();
    }
  }

  Future<void> unlockApp() async {
    final authenticated = await BiometricService.authenticate(
      reason: 'قم بالمصادقة لفتح التطبيق',
    );

    if (authenticated) {
      isLocked.value = false;
      Get.back(); // Close lock screen
    }
  }

  void _showLockScreen() {
    Get.dialog(
      _AppLockScreen(),
      barrierDismissible: false,
      barrierColor: Colors.black87,
    );
  }
}

class _AppLockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLockService = Get.find<AppLockService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0D1117) : Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),

                  SizedBox(height: 40),

                  // Lock Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock, color: Colors.red, size: 40),
                  ),

                  SizedBox(height: 32),

                  // Title
                  Text(
                    'التطبيق مقفل',
                    style: AppTextStyles.cairo24w700.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.primaryDark,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Description
                  Text(
                    'يرجى المصادقة للمتابعة',
                    style: AppTextStyles.cairo16w700.copyWith(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 48),

                  // Unlock Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => appLockService.unlockApp(),
                      icon: Icon(Icons.fingerprint, size: 24),
                      label: FutureBuilder<String>(
                        future: BiometricService.getBiometricTypeText(),
                        builder: (context, snapshot) {
                          return Text(
                            'فتح بـ ${snapshot.data ?? "المصادقة البيومترية"}',
                            style: AppTextStyles.cairo16w700,
                          );
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Alternative unlock (if needed)
                  TextButton(
                    onPressed: () {
                      // Could add PIN unlock as alternative
                      Get.snackbar(
                        'معلومة',
                        'يمكنك فقط استخدام المصادقة البيومترية لفتح التطبيق',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    child: Text(
                      'طرق أخرى للفتح',
                      style: AppTextStyles.cairo14w500.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
