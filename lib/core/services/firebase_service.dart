import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseRemoteConfig? _remoteConfig;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _remoteConfig = FirebaseRemoteConfig.instance;

      LoggerService.info('Firebase initialized successfully');

      await _setupRemoteConfig();
      _initialized = true;
    } catch (e, stackTrace) {
      LoggerService.error('Firebase initialization error', e, stackTrace);
      _initialized = false;
    }
  }

  // ---------------- Remote Config ----------------
  static Future<void> _setupRemoteConfig() async {
    if (_remoteConfig == null) return;

    try {
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );

      await _remoteConfig!.setDefaults({
        'maintenance_mode': false,
        'maintenance_message': 'التطبيق قيد الصيانة حالياً',
        'min_app_version': '1.0.0',
        'force_update': false,
        'show_ads': false,
        'premium_features_enabled': true,
      });

      await _remoteConfig!.fetchAndActivate();
      LoggerService.info('Remote Config setup completed');
    } catch (e, stackTrace) {
      LoggerService.error('Remote Config setup error', e, stackTrace);
    }
  }

  static bool isMaintenanceMode() =>
      _remoteConfig?.getBool('maintenance_mode') ?? false;
  static String getMaintenanceMessage() =>
      _remoteConfig?.getString('maintenance_message') ??
      'التطبيق قيد الصيانة حالياً';

  // Check maintenance mode from Firestore (for admin panel updates)
  static Future<bool> checkMaintenanceModeFromFirestore() async {
    if (_firestore == null) return false;

    try {
      final doc =
          await _firestore!
              .collection('system_settings')
              .doc('remote_config')
              .get();
      if (doc.exists) {
        return doc.data()?['maintenance_mode'] ?? false;
      }
      return false;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error checking maintenance mode from Firestore',
        e,
        stackTrace,
      );
      return false;
    }
  }

  static Future<String> getMaintenanceMessageFromFirestore() async {
    if (_firestore == null) return 'التطبيق قيد الصيانة حالياً';

    try {
      final doc =
          await _firestore!
              .collection('system_settings')
              .doc('remote_config')
              .get();
      if (doc.exists) {
        return doc.data()?['maintenance_message'] ??
            'التطبيق قيد الصيانة حالياً';
      }
      return 'التطبيق قيد الصيانة حالياً';
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error getting maintenance message from Firestore',
        e,
        stackTrace,
      );
      return 'التطبيق قيد الصيانة حالياً';
    }
  }

  static bool needsUpdate(String currentVersion) {
    final minVersion = _remoteConfig?.getString('min_app_version') ?? '1.0.0';
    return _compareVersions(currentVersion, minVersion) < 0;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

  // ---------------- Questions ----------------
  static Future<List<Map<String, dynamic>>> getQuestionsFromFirebase(
    String assessmentType,
  ) async {
    if (_firestore == null) return [];

    try {
      final snapshot =
          await _firestore!
              .collection('assessments')
              .doc(assessmentType)
              .collection('questions')
              .orderBy('order')
              .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error fetching questions', e, stackTrace);
      return [];
    }
  }

  static Future<void> addQuestion({
    required String assessmentType,
    required Map<String, dynamic> questionData,
  }) async {
    if (_firestore == null) return;

    try {
      await _firestore!
          .collection('assessments')
          .doc(assessmentType)
          .collection('questions')
          .add(questionData);

      Get.snackbar(
        'نجح',
        'تم إضافة السؤال بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
      LoggerService.info('Question added successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to add question', e, stackTrace);
      Get.snackbar(
        'خطأ',
        'فشل في إضافة السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> updateQuestion({
    required String assessmentType,
    required String questionId,
    required Map<String, dynamic> questionData,
  }) async {
    if (_firestore == null) return;

    try {
      await _firestore!
          .collection('assessments')
          .doc(assessmentType)
          .collection('questions')
          .doc(questionId)
          .update(questionData);

      Get.snackbar(
        'نجح',
        'تم تحديث السؤال بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
      LoggerService.info('Question updated successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update question', e, stackTrace);
      Get.snackbar(
        'خطأ',
        'فشل في تحديث السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> deleteQuestion({
    required String assessmentType,
    required String questionId,
  }) async {
    if (_firestore == null) return;

    try {
      await _firestore!
          .collection('assessments')
          .doc(assessmentType)
          .collection('questions')
          .doc(questionId)
          .delete();

      Get.snackbar(
        'نجح',
        'تم حذف السؤال بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
      LoggerService.info('Question deleted successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete question', e, stackTrace);
      Get.snackbar(
        'خطأ',
        'فشل في حذف السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------- Assessment Result ----------------
  static Future<void> saveAssessmentResult(Map<String, dynamic> result) async {
    if (_firestore == null) {
      LoggerService.error('Firestore not initialized', null, null);
      return;
    }

    try {
      final enrichedResult = {
        ...result,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'completed',
      };

      LoggerService.info(
        'Saving assessment result: ${enrichedResult.keys.join(', ')}',
      );

      final docRef = await _firestore!
          .collection('assessment_results')
          .add(enrichedResult);

      LoggerService.info('Assessment result saved with ID: ${docRef.id}');

      // Update user stats safely
      if (result['userId'] != null) {
        await _firestore!.collection('users').doc(result['userId']).update({
          'lastAssessmentAt': FieldValue.serverTimestamp(),
          'totalAssessments': FieldValue.increment(1),
          'lastAssessmentId': docRef.id,
          'lastAssessmentType': result['assessmentType'],
        });
        LoggerService.info('User stats updated for: ${result['userId']}');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error saving assessment result', e, stackTrace);
      rethrow;
    }
  }

  // ---------------- Payments ----------------
  static Future<bool> checkPaymentStatus(String userId) async {
    if (_firestore == null) return false;

    try {
      final doc = await _firestore!.collection('payments').doc(userId).get();
      if (!doc.exists) return false;

      final expiryDate = (doc.data()?['expiryDate'] as Timestamp?)?.toDate();
      if (expiryDate == null) return false;

      return DateTime.now().isBefore(expiryDate);
    } catch (e, stackTrace) {
      LoggerService.error('Error checking payment status', e, stackTrace);
      return false;
    }
  }

  static Future<void> recordPayment({
    required String userId,
    required double amount,
    required int durationDays,
  }) async {
    if (_firestore == null) return;

    try {
      final expiryDate = DateTime.now().add(Duration(days: durationDays));

      await _firestore!.collection('payments').doc(userId).set({
        'amount': amount,
        'purchaseDate': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'status': 'active',
      });

      LoggerService.info('Payment recorded for user: $userId');
    } catch (e, stackTrace) {
      LoggerService.error('Error recording payment', e, stackTrace);
    }
  }

  // ---------------- Remote Config Refresh ----------------
  static Future<void> refreshRemoteConfig() async {
    if (_remoteConfig == null) return;

    try {
      await _remoteConfig!.fetchAndActivate();
      LoggerService.info('Remote config refreshed');
    } catch (e, stackTrace) {
      LoggerService.error('Error refreshing remote config', e, stackTrace);
    }
  }

  // ---------------- Leaderboard ----------------
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    if (_firestore == null) {
      LoggerService.error('Firestore not initialized', null, null);
      return [];
    }

    try {
      final snapshot =
          await _firestore!
              .collection('leaderboard')
              .orderBy('totalScore', descending: true)
              .limit(50)
              .get();

      final leaderboard =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'مستخدم',
              'totalScore': data['totalScore'] ?? 0,
              'completedAssessments': data['completedAssessments'] ?? 0,
              'rank': data['rank'] ?? 0,
            };
          }).toList();

      LoggerService.info('Fetched ${leaderboard.length} leaderboard entries');

      return leaderboard;
    } catch (e, stackTrace) {
      LoggerService.error('Error fetching leaderboard', e, stackTrace);
      return [];
    }
  }
}
