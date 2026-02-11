import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class MaintenanceService extends GetxController {
  static MaintenanceService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _maintenanceListener;

  var isMaintenanceMode = false.obs;
  var maintenanceMessage = 'التطبيق قيد الصيانة حالياً'.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Add a small delay to ensure Firebase is initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      checkMaintenanceMode();
      _startMaintenanceListener();
    });
  }

  @override
  void onClose() {
    _maintenanceListener?.cancel();
    super.onClose();
  }

  void _startMaintenanceListener() {
    try {
      _maintenanceListener = _firestore
          .collection('system_settings')
          .doc('remote_config')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.exists && snapshot.data() != null) {
                final data = snapshot.data()!;
                final newMaintenanceMode = data['maintenance_mode'] ?? false;
                final newMessage =
                    data['maintenance_message'] ?? 'التطبيق قيد الصيانة حالياً';

                // Update values
                isMaintenanceMode.value = newMaintenanceMode;
                maintenanceMessage.value = newMessage;

                LoggerService.info(
                  'Maintenance mode updated: $newMaintenanceMode',
                );

                // If maintenance mode is enabled, navigate to maintenance screen
                if (newMaintenanceMode && Get.currentRoute != '/maintenance') {
                  Get.offAllNamed('/maintenance');
                }
              }
            },
            onError: (error) {
              LoggerService.error(
                'Error listening to maintenance mode',
                error,
                null,
              );
            },
          );
    } catch (e, stackTrace) {
      LoggerService.error('Error starting maintenance listener', e, stackTrace);
    }
  }

  Future<void> checkMaintenanceMode() async {
    try {
      isLoading.value = true;

      // Check connectivity first
      if (!ConnectivityService.instance.isConnected.value) {
        LoggerService.info('No internet connection, maintenance mode disabled');
        isMaintenanceMode.value = false;
        maintenanceMessage.value = 'التطبيق قيد الصيانة حالياً';
        return;
      }

      final doc = await _firestore
          .collection('system_settings')
          .doc('remote_config')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout while checking maintenance mode');
            },
          );

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        isMaintenanceMode.value = data['maintenance_mode'] ?? false;
        maintenanceMessage.value =
            data['maintenance_message'] ?? 'التطبيق قيد الصيانة حالياً';
      } else {
        // If document doesn't exist, create it with default values
        await _firestore
            .collection('system_settings')
            .doc('remote_config')
            .set({
              'maintenance_mode': false,
              'maintenance_message': 'التطبيق قيد الصيانة حالياً',
              'createdAt': FieldValue.serverTimestamp(),
            });

        isMaintenanceMode.value = false;
        maintenanceMessage.value = 'التطبيق قيد الصيانة حالياً';
      }

      LoggerService.info(
        'Maintenance mode checked: ${isMaintenanceMode.value}',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error checking maintenance mode', e, stackTrace);
      // Default to false if there's an error
      isMaintenanceMode.value = false;
      maintenanceMessage.value = 'التطبيق قيد الصيانة حالياً';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMaintenanceStatus() async {
    await checkMaintenanceMode();
  }
}
