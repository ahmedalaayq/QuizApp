import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService extends GetxController {
  static ConnectivityService get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker();

  var isConnected = false.obs;
  var connectionType = ConnectivityResult.none.obs;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus> _internetSubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _internetSubscription = _internetChecker.onStatusChange.listen(
      _updateInternetStatus,
    );
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _internetSubscription.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);

      // Also check actual internet connection
      final hasInternet = await _internetChecker.hasConnection;
      isConnected.value = hasInternet;
    } catch (e) {
      // If connectivity check fails, assume we're offline
      isConnected.value = false;
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    connectionType.value = result;
    final wasConnected = isConnected.value;

    if (result == ConnectivityResult.none) {
      isConnected.value = false;
      if (wasConnected) {
        _showOfflineMessage();
      }
    } else {
      // Check actual internet connectivity
      final hasInternet = await _internetChecker.hasConnection;
      isConnected.value = hasInternet;

      if (hasInternet && !wasConnected) {
        _showOnlineMessage();
      } else if (!hasInternet && wasConnected) {
        _showNoInternetMessage();
      }
    }
  }

  void _updateInternetStatus(InternetConnectionStatus status) {
    final wasConnected = isConnected.value;

    switch (status) {
      case InternetConnectionStatus.connected:
        isConnected.value = true;
        if (!wasConnected) {
          _showOnlineMessage();
        }
        break;
      case InternetConnectionStatus.disconnected:
        isConnected.value = false;
        _showOfflineMessage();
        break;
    }
  }

  void _showOnlineMessage() {
    // Only show if Get context is available and we have a valid context
    if (!Get.isRegistered<GetMaterialController>()) return;

    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      // Don't show online message on app startup - only when reconnecting
      // This prevents the annoying "connected to internet" message on app launch
    } catch (e) {
      // Silently handle snackbar errors during app initialization
    }
  }

  void _showOfflineMessage() {
    // Only show if Get context is available and we have a valid context
    if (!Get.isRegistered<GetMaterialController>()) return;

    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'غير متصل',
        'لا يوجد اتصال بالإنترنت - بعض الميزات قد لا تعمل',
        snackPosition: SnackPosition.TOP,
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Silently handle snackbar errors during app initialization
    }
  }

  void _showNoInternetMessage() {
    // Only show if Get context is available and we have a valid context
    if (!Get.isRegistered<GetMaterialController>()) return;

    try {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'لا يوجد إنترنت',
        'متصل بالشبكة ولكن لا يوجد اتصال بالإنترنت',
        snackPosition: SnackPosition.TOP,
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.orange,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Silently handle snackbar errors during app initialization
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        isConnected.value = false;
        return false;
      }

      // Check actual internet connectivity with timeout
      final hasInternet = await _internetChecker.hasConnection;
      isConnected.value = hasInternet;
      return hasInternet;
    } catch (e) {
      // If check fails, assume offline
      isConnected.value = false;
      return false;
    }
  }

  String get connectionTypeString {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }
}
