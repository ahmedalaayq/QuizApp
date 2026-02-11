import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarService {
  static void showSuccess(String title, String message) {
    final isDarkMode = Get.isDarkMode;
    Get.snackbar(
      title,
      message,
      backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.green,
      colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String title, String message) {
    final isDarkMode = Get.isDarkMode;
    Get.snackbar(
      title,
      message,
      backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
      colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void showWarning(String title, String message) {
    final isDarkMode = Get.isDarkMode;
    Get.snackbar(
      title,
      message,
      backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.orange,
      colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  static void showInfo(String title, String message) {
    final isDarkMode = Get.isDarkMode;
    Get.snackbar(
      title,
      message,
      backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.blue,
      colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  static void showLoading(String title, String message) {
    final isDarkMode = Get.isDarkMode;
    Get.snackbar(
      title,
      message,
      backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.blue,
      colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      showProgressIndicator: true,
    );
  }

  static void showNetworkError() {
    showError('خطأ في الشبكة', 'يرجى التحقق من الاتصال بالإنترنت');
  }

  static void showConnectionStatus(bool isConnected) {
    if (isConnected) {
      showSuccess('متصل', 'تم الاتصال بالإنترنت');
    } else {
      showError('غير متصل', 'لا يوجد اتصال بالإنترنت');
    }
  }
}
