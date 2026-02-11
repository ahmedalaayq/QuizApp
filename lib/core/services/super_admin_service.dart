import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class SuperAdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verify superAdmin password from Firestore
  static Future<bool> verifySuperAdminPassword(String password) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // Get the hashed password from Firestore
      final doc =
          await _firestore
              .collection('system_settings')
              .doc('super_admin_config')
              .get();

      if (!doc.exists) {
        await _createDefaultSuperAdminConfig();
        return password == 'engAhmedEmad@A12345';
      }

      final data = doc.data()!;
      final storedHash = data['passwordHash'] as String?;

      if (storedHash == null) {
        return false;
      }

      // Hash the provided password and compare
      final inputHash = _hashPassword(password);
      return inputHash == storedHash;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error verifying super admin password',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Create default super admin configuration
  static Future<void> _createDefaultSuperAdminConfig() async {
    try {
      final defaultPassword = 'engAhmedEmad@A12345';
      final hashedPassword = _hashPassword(defaultPassword);

      await _firestore
          .collection('system_settings')
          .doc('super_admin_config')
          .set({
            'passwordHash': hashedPassword,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
            'description': 'Super Admin configuration for role management',
          });

      LoggerService.info('Default super admin config created');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error creating default super admin config',
        e,
        stackTrace,
      );
    }
  }

  /// Update super admin password
  static Future<bool> updateSuperAdminPassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      // Verify current password first
      final isCurrentValid = await verifySuperAdminPassword(currentPassword);
      if (!isCurrentValid) {
        return false;
      }

      // Hash new password and update
      final newHash = _hashPassword(newPassword);

      await _firestore
          .collection('system_settings')
          .doc('super_admin_config')
          .update({
            'passwordHash': newHash,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      LoggerService.info('Super admin password updated successfully');
      return true;
    } catch (e, stackTrace) {
      LoggerService.error('Error updating super admin password', e, stackTrace);
      return false;
    }
  }

  /// Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode('$password QuizApp_Salt_2024'); // Add salt
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Log super admin actions
  static Future<void> logSuperAdminAction(
    String action,
    String description,
    Map<String, dynamic> details,
  ) async {
    try {
      await _firestore.collection('super_admin_logs').add({
        'action': action,
        'description': description,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      LoggerService.error('Error logging super admin action', e, stackTrace);
    }
  }
}
