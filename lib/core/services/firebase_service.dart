import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class FirebaseService {
  static FirebaseFirestore? firestore;
  static FirebaseRemoteConfig? _remoteConfig;
  static bool _initialized = false;

  // ================= INIT =================
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      firestore = FirebaseFirestore.instance;
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _setupRemoteConfig();

      _initialized = true;

      LoggerService.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Firebase initialization error', e, stackTrace);
      _initialized = false;
    }
  }

  // ================= REMOTE CONFIG =================
  static Future<void> _setupRemoteConfig() async {
    if (_remoteConfig == null) return;

    await _remoteConfig!.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1), // 🔥 آمن للإنتاج
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
  }

  static bool isMaintenanceMode() =>
      _remoteConfig?.getBool('maintenance_mode') ?? false;

  static String getMaintenanceMessage() =>
      _remoteConfig?.getString('maintenance_message') ??
      'التطبيق قيد الصيانة حالياً';

  static bool needsUpdate(String currentVersion) {
    final minVersion = _remoteConfig?.getString('min_app_version') ?? '1.0.0';

    return _compareVersions(currentVersion, minVersion) < 0;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.');
    final parts2 = v2.split('.');

    final maxLength =
        parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLength; i++) {
      final p1 = i < parts1.length ? int.tryParse(parts1[i]) ?? 0 : 0;
      final p2 = i < parts2.length ? int.tryParse(parts2[i]) ?? 0 : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    return 0;
  }

  // ================= QUESTIONS =================
  static Future<List<Map<String, dynamic>>> getQuestionsFromFirebase(
    String assessmentType,
  ) async {
    if (firestore == null) return [];

    try {
      final snapshot =
          await firestore!
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

  // ================= SAVE ASSESSMENT RESULT =================
  static Future<void> saveAssessmentResult(Map<String, dynamic> result) async {
    if (firestore == null) return;

    try {
      final assessmentId = result['id'];

      DocumentReference docRef;

      if (assessmentId != null) {
        docRef = firestore!.collection('assessment_results').doc(assessmentId);

        final existing = await docRef.get();
        if (existing.exists) {
          LoggerService.warning('Assessment already exists: $assessmentId');
          return;
        }

        await docRef.set({
          ...result,
          'createdAt': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'version': result['version'] ?? '2.0',
        });
      } else {
        docRef = await firestore!.collection('assessment_results').add({
          ...result,
          'createdAt': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
          'version': result['version'] ?? '2.0',
        });
      }

      // ✅ تحديث user stats (بدون كسر أي حاجة)
      if (result['userId'] != null) {
        await firestore!.collection('users').doc(result['userId']).update({
          'lastAssessmentAt': FieldValue.serverTimestamp(),
          'lastAssessmentId': docRef.id,
          'lastAssessmentType': result['assessmentType'],
          'lastAssessmentScore': result['score'] ?? result['totalScore'],
          'totalAssessments': FieldValue.increment(1),
        });
      }

      LoggerService.info('Assessment saved successfully: ${docRef.id}');
    } catch (e, stackTrace) {
      LoggerService.error('Error saving assessment result', e, stackTrace);
      rethrow;
    }
  }

  // ================= LEADERBOARD =================
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    if (firestore == null) return [];

    try {
      final snapshot =
          await firestore!
              .collection('leaderboard')
              .orderBy('totalScore', descending: true)
              .limit(50)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'مستخدم',
          'totalScore': data['totalScore'] ?? 0,
          'completedAssessments': data['completedAssessments'] ?? 0,
          'rank': data['rank'] ?? 0,
        };
      }).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error fetching leaderboard', e, stackTrace);
      return [];
    }
  }

  // ================= PAYMENT =================
  static Future<bool> checkPaymentStatus(String userId) async {
    if (firestore == null) return false;

    try {
      final doc = await firestore!.collection('payments').doc(userId).get();

      if (!doc.exists) return false;

      final expiryDate = (doc.data()?['expiryDate'] as Timestamp?)?.toDate();

      if (expiryDate == null) return false;

      return DateTime.now().isBefore(expiryDate);
    } catch (e, stackTrace) {
      LoggerService.error('Error checking payment status', e, stackTrace);
      return false;
    }
  }

  static Future<bool> checkMaintenanceMode() async {
    try {
      if (firestore != null) {
        final doc =
            await firestore!
                .collection('system_settings')
                .doc('remote_config')
                .get();

        if (doc.exists && doc.data()?['maintenance_mode'] != null) {
          return doc.data()!['maintenance_mode'] as bool;
        }
      }

      // fallback to Remote Config
      return _remoteConfig?.getBool('maintenance_mode') ?? false;
    } catch (e, stackTrace) {
      LoggerService.error('Error checking maintenance mode', e, stackTrace);

      return false;
    }
  }

  // static Future<String> getMaintenanceMessage() async {
  //   try {
  //     if (firestore != null) {
  //       final doc =
  //           await firestore!
  //               .collection('system_settings')
  //               .doc('remote_config')
  //               .get();

  //       if (doc.exists && doc.data()?['maintenance_message'] != null) {
  //         return doc.data()!['maintenance_message'] as String;
  //       }
  //     }

  //     // fallback to Remote Config
  //     return _remoteConfig?.getString('maintenance_message') ??
  //         'التطبيق قيد الصيانة حالياً';
  //   } catch (e, stackTrace) {
  //     LoggerService.error('Error getting maintenance message', e, stackTrace);

  //     return 'التطبيق قيد الصيانة حالياً';
  //   }
  // }
}
