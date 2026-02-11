import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

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

      await _setupRemoteConfig();
      _initialized = true;
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  static Future<void> _setupRemoteConfig() async {
    if (_remoteConfig == null) return;

    try {
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
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
    } catch (e) {
      print('Remote Config setup error: $e');
    }
  }

  // التحقق من وضع الصيانة
  static bool isMaintenanceMode() {
    return _remoteConfig?.getBool('maintenance_mode') ?? false;
  }

  // الحصول على رسالة الصيانة
  static String getMaintenanceMessage() {
    return _remoteConfig?.getString('maintenance_message') ??
        'التطبيق قيد الصيانة حالياً';
  }

  // التحقق من الحاجة للتحديث
  static bool needsUpdate(String currentVersion) {
    final minVersion = _remoteConfig?.getString('min_app_version') ?? '1.0.0';
    return _compareVersions(currentVersion, minVersion) < 0;
  }

  // مقارنة الإصدارات
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

  // الحصول على الأسئلة من Firestore
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
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  // حفظ نتيجة في Firestore (اختياري)
  static Future<void> saveResultToFirebase(Map<String, dynamic> result) async {
    if (_firestore == null) return;

    try {
      await _firestore!.collection('results').add({
        ...result,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving result: $e');
    }
  }

  // الحصول على الإحصائيات العامة
  static Future<Map<String, dynamic>> getGlobalStats() async {
    if (_firestore == null) return {};

    try {
      final doc = await _firestore!.collection('stats').doc('global').get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error fetching stats: $e');
      return {};
    }
  }

  // إضافة سؤال جديد (للمسؤول)
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
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تحديث سؤال (للمسؤول)
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
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // حذف سؤال (للمسؤول)
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
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف السؤال',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // التحقق من حالة الدفع (للنسخة المدفوعة)
  static Future<bool> checkPaymentStatus(String userId) async {
    if (_firestore == null) return false;

    try {
      final doc = await _firestore!.collection('payments').doc(userId).get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final expiryDate = (data['expiryDate'] as Timestamp).toDate();

      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  // تسجيل عملية دفع
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
    } catch (e) {
      print('Error recording payment: $e');
    }
  }

  // تحديث Remote Config
  static Future<void> refreshRemoteConfig() async {
    if (_remoteConfig == null) return;

    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      print('Error refreshing remote config: $e');
    }
  }
}
