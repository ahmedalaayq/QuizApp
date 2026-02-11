import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    String reason = 'يرجى المصادقة للمتابعة',
  }) async {
    try {
      final isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        return false;
      } else if (e.code == auth_error.notEnrolled) {
        return false;
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getBiometricTypeText() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'غير متاح';
    }

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'بصمة الإصبع';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'بصمة العين';
    } else {
      return 'المصادقة البيومترية';
    }
  }

  static Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    // ignore: empty_catches
    } catch (e) {
      
    }
  }
}
