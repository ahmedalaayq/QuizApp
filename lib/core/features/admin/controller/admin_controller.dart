import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/services/maintenance_service.dart';
import 'package:quiz_app/core/services/super_admin_service.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var error = ''.obs;

  // User Management
  var users = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;
  var totalUsers = 0.obs;
  var activeUsers = 0.obs;
  var therapists = 0.obs;
  var admins = 0.obs;
  var students = 0.obs;

  // System Settings
  var isMaintenanceMode = false.obs;
  var maintenanceMessage = 'التطبيق قيد الصيانة حالياً'.obs;
  var appVersion = '1.0.0'.obs;
  var forceUpdate = false.obs;
  var showAds = false.obs;
  var premiumFeaturesEnabled = true.obs;

  // Analytics
  var totalAssessments = 0.obs;
  var todayAssessments = 0.obs;
  var weeklyAssessments = 0.obs;
  var monthlyAssessments = 0.obs;
  var systemHealth = 'جيد'.obs;

  // Notifications
  var pendingNotifications = 0.obs;
  var systemAlerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';

      await Future.wait([
        loadUsers(),
        loadSystemSettings(),
        loadAnalytics(),
        loadSystemAlerts(),
      ]);
    } catch (e, stackTrace) {
      LoggerService.error('Error loading dashboard data', e, stackTrace);
      error.value = 'فشل في تحميل بيانات لوحة التحكم';
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== User Management ====================

  Future<void> loadUsers() async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final querySnapshot =
          await _firestore
              .collection('users')
              .orderBy('createdAt', descending: true)
              .get();

      users.value =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            data['uid'] = doc.id;
            return data;
          }).toList();

      filteredUsers.value = users;
      _updateUserStatistics();

      LoggerService.info('Loaded ${users.length} users');
    } catch (e, stackTrace) {
      LoggerService.error('Error loading users', e, stackTrace);
      throw Exception('فشل في تحميل المستخدمين: ${e.toString()}');
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value =
          users.where((user) {
            final name = (user['name'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            final role = (user['role'] ?? '').toString().toLowerCase();
            final searchQuery = query.toLowerCase();

            return name.contains(searchQuery) ||
                email.contains(searchQuery) ||
                role.contains(searchQuery);
          }).toList();
    }
  }

  Future<void> toggleUserStatus(String uid, bool isActive) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      await _firestore.collection('users').doc(uid).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });

      // Update local data
      final userIndex = users.indexWhere((user) => user['uid'] == uid);
      if (userIndex != -1) {
        users[userIndex]['isActive'] = isActive;
        users.refresh();
        filteredUsers.refresh();
        _updateUserStatistics();
      }

      // Log action
      await _logAdminAction('toggle_user_status', 'تغيير حالة المستخدم', {
        'userId': uid,
        'newStatus': isActive,
      });

      Get.snackbar(
        'نجح',
        isActive ? 'تم تفعيل المستخدم بنجاح' : 'تم تعطيل المستخدم بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error toggling user status', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في تحديث حالة المستخدم');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });

      // Update local data
      final userIndex = users.indexWhere((user) => user['uid'] == uid);
      if (userIndex != -1) {
        users[userIndex]['role'] = newRole;
        users.refresh();
        filteredUsers.refresh();
        _updateUserStatistics();
      }

      // If updating current user's role, refresh AuthService
      if (uid == _auth.currentUser?.uid) {
        final authService = Get.find<AuthService>();
        await authService.refreshUserRole();

        // Force UI update by refreshing the home view
        Get.forceAppUpdate();
      }

      // Also refresh any other user who might be viewing their profile
      await loadUsers(); // Refresh the users list to show updated roles

      // Force update statistics
      _updateUserStatistics();

      // Log action
      await _logAdminAction('update_user_role', 'تحديث دور المستخدم', {
        'userId': uid,
        'newRole': newRole,
      });

      Get.snackbar(
        'نجح',
        'تم تحديث دور المستخدم بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error updating user role', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في تحديث دور المستخدم');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete user assessments and related data
      final assessmentsQuery =
          await _firestore
              .collection('assessment_results')
              .where('userId', isEqualTo: uid)
              .get();

      final batch = _firestore.batch();
      for (final doc in assessmentsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Remove from local data
      users.removeWhere((user) => user['uid'] == uid);
      filteredUsers.removeWhere((user) => user['uid'] == uid);
      _updateUserStatistics();

      // Log action
      await _logAdminAction('delete_user', 'حذف مستخدم', {'userId': uid});

      Get.snackbar(
        'نجح',
        'تم حذف المستخدم بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error deleting user', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في حذف المستخدم');
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    int? age,
    String? gender,
    String? phone,
  }) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // Create user with Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Save user data to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'role': role,
          'age': age,
          'gender': gender,
          'phone': phone,
          'isActive': true,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid,
        });

        // Log action
        await _logAdminAction('create_user', 'إنشاء مستخدم جديد', {
          'email': email,
          'role': role,
        });

        // Reload users
        await loadUsers();

        Get.snackbar(
          'نجح',
          'تم إنشاء المستخدم بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error creating user', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في إنشاء المستخدم: ${e.toString()}');
    }
  }

  // ==================== System Settings ====================

  Future<void> loadSystemSettings() async {
    try {
      // Load maintenance mode from Firestore
      isMaintenanceMode.value =
          await FirebaseService.checkMaintenanceModeFromFirestore();
      maintenanceMessage.value =
          await FirebaseService.getMaintenanceMessageFromFirestore();

      // Load other settings from Firestore
      final settingsDoc =
          await _firestore
              .collection('system_settings')
              .doc('app_config')
              .get();

      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        appVersion.value = data['appVersion'] ?? '1.0.0';
        forceUpdate.value = data['forceUpdate'] ?? false;
        showAds.value = data['showAds'] ?? false;
        premiumFeaturesEnabled.value = data['premiumFeaturesEnabled'] ?? true;
      }

      LoggerService.info('System settings loaded');
    } catch (e, stackTrace) {
      LoggerService.error('Error loading system settings', e, stackTrace);
    }
  }

  Future<void> toggleMaintenanceMode(bool enabled, [String? message]) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      await _firestore.collection('system_settings').doc('remote_config').set({
        'maintenance_mode': enabled,
        'maintenance_message': message ?? 'التطبيق قيد الصيانة حالياً',
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      }, SetOptions(merge: true));

      isMaintenanceMode.value = enabled;
      if (message != null) {
        maintenanceMessage.value = message;
      }

      // Update MaintenanceService immediately
      try {
        final maintenanceService = Get.find<MaintenanceService>();
        maintenanceService.isMaintenanceMode.value = enabled;
        if (message != null) {
          maintenanceService.maintenanceMessage.value = message;
        }
      } catch (e) {
        // MaintenanceService might not be initialized yet
        LoggerService.error('MaintenanceService not found', e, null);
      }

      // Log action
      await _logAdminAction('toggle_maintenance', 'تغيير وضع الصيانة', {
        'enabled': enabled,
        'message': message,
      });

      Get.snackbar(
        'نجح',
        enabled ? 'تم تفعيل وضع الصيانة' : 'تم إلغاء وضع الصيانة',
        backgroundColor: enabled ? Colors.orange : Colors.green,
        colorText: Colors.white,
      );

      // If maintenance mode is enabled, navigate to maintenance screen
      if (enabled) {
        // Give a small delay for the snackbar to show
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed('/maintenance');
        });
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error toggling maintenance mode', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في تحديث وضع الصيانة');
    }
  }

  Future<void> updateAppSettings({
    String? version,
    bool? forceUpdateFlag,
    bool? showAdsFlag,
    bool? premiumEnabled,
  }) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      };

      if (version != null) {
        updates['appVersion'] = version;
        appVersion.value = version;
      }
      if (forceUpdateFlag != null) {
        updates['forceUpdate'] = forceUpdateFlag;
        forceUpdate.value = forceUpdateFlag;
      }
      if (showAdsFlag != null) {
        updates['showAds'] = showAdsFlag;
        showAds.value = showAdsFlag;
      }
      if (premiumEnabled != null) {
        updates['premiumFeaturesEnabled'] = premiumEnabled;
        premiumFeaturesEnabled.value = premiumEnabled;
      }

      await _firestore
          .collection('system_settings')
          .doc('app_config')
          .set(updates, SetOptions(merge: true));

      // Log action
      await _logAdminAction(
        'update_app_settings',
        'تحديث إعدادات التطبيق',
        updates,
      );

      Get.snackbar(
        'نجح',
        'تم تحديث إعدادات التطبيق بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error updating app settings', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في تحديث إعدادات التطبيق');
    }
  }

  // ==================== Analytics ====================

  Future<void> loadAnalytics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      final monthAgo = DateTime(now.year, now.month - 1, now.day);

      // Get total assessments
      final totalQuery =
          await _firestore.collection('assessment_results').get();
      totalAssessments.value = totalQuery.docs.length;

      // Get today's assessments
      final todayQuery =
          await _firestore
              .collection('assessment_results')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: today.toIso8601String(),
              )
              .get();
      todayAssessments.value = todayQuery.docs.length;

      // Get weekly assessments
      final weeklyQuery =
          await _firestore
              .collection('assessment_results')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: weekAgo.toIso8601String(),
              )
              .get();
      weeklyAssessments.value = weeklyQuery.docs.length;

      // Get monthly assessments
      final monthlyQuery =
          await _firestore
              .collection('assessment_results')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: monthAgo.toIso8601String(),
              )
              .get();
      monthlyAssessments.value = monthlyQuery.docs.length;

      // System health check
      systemHealth.value = _calculateSystemHealth();

      LoggerService.info('Analytics loaded');
    } catch (e, stackTrace) {
      LoggerService.error('Error loading analytics', e, stackTrace);
    }
  }

  String _calculateSystemHealth() {
    // Simple health calculation based on user activity
    final activeUserPercentage =
        totalUsers.value > 0 ? (activeUsers.value / totalUsers.value) * 100 : 0;

    if (activeUserPercentage > 80) return 'ممتاز';
    if (activeUserPercentage > 60) return 'جيد';
    if (activeUserPercentage > 40) return 'متوسط';
    return 'يحتاج تحسين';
  }

  // ==================== Notifications & Alerts ====================

  Future<void> loadSystemAlerts() async {
    try {
      final alertsQuery =
          await _firestore
              .collection('system_alerts')
              .orderBy('createdAt', descending: true)
              .limit(10)
              .get();

      systemAlerts.value =
          alertsQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      pendingNotifications.value =
          systemAlerts.where((alert) => alert['status'] == 'pending').length;

      LoggerService.info('System alerts loaded');
    } catch (e, stackTrace) {
      LoggerService.error('Error loading system alerts', e, stackTrace);
    }
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    String? targetRole,
    List<String>? targetUsers,
  }) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      await _firestore.collection('notifications').add({
        'title': title,
        'message': message,
        'targetRole': targetRole,
        'targetUsers': targetUsers,
        'type': 'broadcast',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });

      // Log action
      await _logAdminAction('send_notification', 'إرسال إشعار جماعي', {
        'title': title,
        'targetRole': targetRole,
      });

      Get.snackbar(
        'نجح',
        'تم إرسال الإشعار بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error sending notification', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في إرسال الإشعار');
    }
  }

  // ==================== Data Management ====================

  Future<void> exportAllData() async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // This would typically generate and download a comprehensive data export
      // For now, we'll just log the action
      await _logAdminAction('export_data', 'تصدير جميع البيانات', {
        'timestamp': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        'نجح',
        'تم بدء عملية تصدير البيانات',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error exporting data', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في تصدير البيانات');
    }
  }

  Future<void> backupDatabase() async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      await _firestore.collection('system_backups').add({
        'type': 'manual_backup',
        'status': 'initiated',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });

      // Log action
      await _logAdminAction('backup_database', 'نسخ احتياطي للقاعدة', {
        'type': 'manual',
      });

      Get.snackbar(
        'نجح',
        'تم بدء عملية النسخ الاحتياطي',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error backing up database', e, stackTrace);
      Get.snackbar('خطأ', 'فشل في النسخ الاحتياطي');
    }
  }

  // ==================== Helper Methods ====================

  void _updateUserStatistics() {
    totalUsers.value = users.length;
    activeUsers.value = users.where((user) => user['isActive'] == true).length;
    therapists.value =
        users.where((user) => user['role'] == 'therapist').length;
    admins.value =
        users
            .where(
              (user) => user['role'] == 'admin' || user['role'] == 'superAdmin',
            )
            .length;
    students.value = users.where((user) => user['role'] == 'student').length;
  }

  Future<void> _logAdminAction(
    String action,
    String description,
    Map<String, dynamic> details,
  ) async {
    try {
      await _firestore.collection('admin_logs').add({
        'action': action,
        'description': description,
        'details': details,
        'adminId': _auth.currentUser?.uid,
        'adminEmail': _auth.currentUser?.email,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      LoggerService.error('Error logging admin action', e, stackTrace);
    }
  }

  // ==================== Getters ====================

  List<Map<String, dynamic>> get recentUsers => users.take(5).toList();

  Map<String, int> get usersByRole => {
    'students': students.value,
    'therapists': therapists.value,
    'admins': admins.value,
  };

  double get activeUserPercentage =>
      totalUsers.value > 0 ? (activeUsers.value / totalUsers.value) * 100 : 0;

  // ==================== SuperAdmin Password Management ====================

  /// Change SuperAdmin password (only for SuperAdmin users)
  Future<bool> changeSuperAdminPassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // Use SuperAdminService to update password
      final success = await SuperAdminService.updateSuperAdminPassword(
        currentPassword,
        newPassword,
      );

      if (success) {
        // Log the password change action
        await SuperAdminService.logSuperAdminAction(
          'password_change',
          'SuperAdmin password changed',
          {
            'changedBy': _auth.currentUser?.uid ?? 'unknown',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        LoggerService.info('SuperAdmin password changed successfully');
      }

      return success;
    } catch (e, stackTrace) {
      LoggerService.error('Error changing SuperAdmin password', e, stackTrace);
      rethrow;
    }
  }
}
