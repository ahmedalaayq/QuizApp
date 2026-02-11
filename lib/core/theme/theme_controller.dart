import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/user_settings_model.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }


  void _loadThemeFromStorage() {
    final settings = HiveService.getSettings();
    if (settings != null) {
      isDarkMode.value = settings.isDarkMode;
      themeMode.value = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }


  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    themeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  
    final currentSettings = HiveService.getSettings() ?? UserSettings();
    await HiveService.saveSettings(
      currentSettings.copyWith(isDarkMode: isDarkMode.value),
    );

    Get.changeThemeMode(themeMode.value);
  }


  Future<void> setTheme(bool dark) async {
    isDarkMode.value = dark;
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;

    final currentSettings = HiveService.getSettings() ?? UserSettings();
    await HiveService.saveSettings(currentSettings.copyWith(isDarkMode: dark));

    Get.changeThemeMode(themeMode.value);
  }
}
