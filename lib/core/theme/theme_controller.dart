import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/user_settings_model.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
    _updateSystemUIOverlay();

    // Listen to theme changes
    ever(themeMode, (_) {
      _updateSystemUIOverlay();
      _saveThemeToStorage();
    });

    // Listen to system theme changes
    ever(isDarkMode, (_) {
      _updateSystemUIOverlay();
    });
  }

  void _loadThemeFromStorage() {
    final settings = HiveService.getSettings();
    if (settings != null && settings.themeMode != null) {
      final savedTheme = settings.themeMode!;
      switch (savedTheme) {
        case 'light':
          themeMode.value = ThemeMode.light;
          isDarkMode.value = false;
          break;
        case 'dark':
          themeMode.value = ThemeMode.dark;
          isDarkMode.value = true;
          break;
        case 'system':
          themeMode.value = ThemeMode.system;
          isDarkMode.value = Get.isPlatformDarkMode;
          break;
      }
    } else {
      // Default to system theme
      themeMode.value = ThemeMode.system;
      isDarkMode.value = Get.isPlatformDarkMode;
    }
  }

  void _saveThemeToStorage() {
    final currentSettings = HiveService.getSettings() ?? UserSettings();
    String themeModeString;

    switch (themeMode.value) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    HiveService.saveSettings(
      currentSettings.copyWith(
        isDarkMode: isDarkMode.value,
        themeMode: themeModeString,
      ),
    );
  }

  void _updateSystemUIOverlay() {
    final brightness = _getCurrentBrightness();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor:
            brightness == Brightness.dark
                ? const Color(0xFF0D1117)
                : Colors.white,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Brightness _getCurrentBrightness() {
    switch (themeMode.value) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return Get.isPlatformDarkMode ? Brightness.dark : Brightness.light;
    }
  }

  Future<void> toggleTheme() async {
    switch (themeMode.value) {
      case ThemeMode.light:
        await setDarkMode();
        break;
      case ThemeMode.dark:
        await setSystemMode();
        break;
      case ThemeMode.system:
        await setLightMode();
        break;
    }
  }

  Future<void> setLightMode() async {
    themeMode.value = ThemeMode.light;
    isDarkMode.value = false;
    Get.changeThemeMode(ThemeMode.light);
  }

  Future<void> setDarkMode() async {
    themeMode.value = ThemeMode.dark;
    isDarkMode.value = true;
    Get.changeThemeMode(ThemeMode.dark);
  }

  Future<void> setSystemMode() async {
    themeMode.value = ThemeMode.system;
    isDarkMode.value = Get.isPlatformDarkMode;
    Get.changeThemeMode(ThemeMode.system);
  }

  Future<void> setTheme(bool dark) async {
    if (dark) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  String get currentThemeName {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي (النظام)';
    }
  }

  IconData get currentThemeIcon {
    switch (themeMode.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  bool get isCurrentlyDark {
    switch (themeMode.value) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return Get.isPlatformDarkMode;
    }
  }
}
