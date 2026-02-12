import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var currentUser = Rxn<User>();
  var userRole = ''.obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check current auth state first
    final currentFirebaseUser = _auth.currentUser;
    if (currentFirebaseUser != null) {
      currentUser.value = currentFirebaseUser;
      isLoggedIn.value = true;
      // Force reload user role from Firestore
      _loadUserRole(currentFirebaseUser.uid);
    }

    // Listen to auth state changes
    currentUser.bindStream(_auth.authStateChanges());
    ever(currentUser, _handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      isLoggedIn.value = false;
      userRole.value = '';
    } else {
      isLoggedIn.value = true;
      await _loadUserRole(user.uid);
    }
  }

  // Method to handle navigation after app is fully initialized
  void navigateBasedOnAuthState() {
    if (currentUser.value == null) {
      Get.offAllNamed(AppRoutes.loginView);
    } else {
      Get.offAllNamed('/home');
    }
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      // Always try to load from Firestore first, then fallback to cache
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final role = doc.data()?['role'] ?? 'student';
          userRole.value = role;

          // Cache the role locally for offline access
          try {
            await HiveService.saveData('user_role_$uid', role);
          } catch (e) {
            // If Hive fails, continue without caching
            LoggerService.error('Failed to cache user role', e, null);
          }
          return;
        }
      } catch (firestoreError) {
        // If Firestore fails, try to load from cache
        LoggerService.error(
          'Failed to load role from Firestore',
          firestoreError,
          null,
        );
      }

      // Load from local cache if Firestore failed
      try {
        final cachedRole = HiveService.getData('user_role_$uid');
        if (cachedRole != null) {
          userRole.value = cachedRole;
          return;
        }
      } catch (e) {
        // If Hive fails, continue with default
        LoggerService.error('Failed to load cached role', e, null);
      }

      // Fallback to default role if everything fails
      userRole.value = 'student';
    } catch (e) {
      userRole.value = 'student';
      LoggerService.error('Failed to load user role', e, null);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    String? phone,
    String? occupation,
    String role = 'student',
  }) async {
    UserCredential? credential;
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        Get.snackbar('خطأ', 'يرجى التحقق من الاتصال بالإنترنت');
        return false;
      }

      isLoading.value = true;

      // Enhanced validation
      final validationErrors = _validateSignUpData(email, password, name, age);
      if (validationErrors.isNotEmpty) {
        _showValidationErrors(validationErrors);
        return false;
      }

      // Create user with Firebase Auth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        final isDarkMode = Get.isDarkMode;
        Get.snackbar(
          'خطأ',
          'فشل في إنشاء الحساب',
          backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
          colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        );
        return false;
      }

      try {
        // Update display name
        await credential.user?.updateDisplayName(name);

        // Send email verification FIRST
        await credential.user!.sendEmailVerification();

        // Save user data to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'age': age,
          'gender': gender,
          'phone': phone ?? '',
          'occupation': occupation ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'emailVerified': false, // Will be updated when verified
          'profileCompleted': true,
        });

        // Verify that data was saved successfully with retry mechanism
        int retryCount = 0;
        bool dataSaved = false;

        while (retryCount < 3 && !dataSaved) {
          try {
            final savedDoc =
                await _firestore
                    .collection('users')
                    .doc(credential.user!.uid)
                    .get();

            if (savedDoc.exists && savedDoc.data() != null) {
              dataSaved = true;
              LoggerService.info(
                'User data successfully saved to Firestore with ${savedDoc.data()!.keys.length} fields',
              );
            } else {
              retryCount++;
              if (retryCount < 3) {
                await Future.delayed(Duration(seconds: retryCount));
              }
            }
          } catch (e) {
            retryCount++;
            if (retryCount < 3) {
              await Future.delayed(Duration(seconds: retryCount));
            }
          }
        }

        if (!dataSaved) {
          throw Exception(
            'فشل في حفظ بيانات المستخدم في قاعدة البيانات بعد عدة محاولات',
          );
        }

        userRole.value = role;

        // Cache the role locally
        try {
          await HiveService.saveData('user_role_${credential.user!.uid}', role);
        } catch (e) {
          LoggerService.error(
            'Failed to cache user role during signup',
            e,
            null,
          );
        }

        // Sign out the user until email is verified
        await _auth.signOut();

        Get.snackbar(
          'تم إنشاء الحساب',
          'تم إرسال رابط التحقق إلى بريدك الإلكتروني. يرجى تأكيد البريد الإلكتروني قبل تسجيل الدخول.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        Get.toNamed(AppRoutes.loginView);

        return true;
      } catch (firestoreError) {
        // If Firestore save fails, delete the created user
        await credential.user?.delete();
        throw Exception(
          'فشل في حفظ بيانات المستخدم: ${firestoreError.toString()}',
        );
      }
    } on FirebaseAuthException catch (e) {
      // If user was created but Firestore failed, clean up
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (deleteError) {
          // Log delete error but don't show to user
        }
      }

      String message = _getErrorMessage(e.code);
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'خطأ في التسجيل',
        message,
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      );
      return false;
    } catch (e) {
      // If user was created but Firestore failed, clean up
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (deleteError) {
          // Log delete error but don't show to user
        }
      }

      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'خطأ غير متوقع',
        e.toString(),
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        Get.snackbar('خطأ', 'يرجى التحقق من الاتصال بالإنترنت');
        return false;
      }

      isLoading.value = true;

      // Validate input
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('خطأ', 'يرجى ملء جميع الحقول');
        return false;
      }

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        Get.snackbar(
          'خطأ',
          'فشل في تسجيل الدخول',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Check if email is verified
      await credential.user!.reload(); // Refresh user data
      if (!credential.user!.emailVerified) {
        await _auth.signOut(); // Sign out unverified user
        Get.dialog(
          AlertDialog(
            backgroundColor: AppColors.whiteColor,
            surfaceTintColor: AppColors.primaryLight, // يعطي تأثير M3 subtle
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Row(
              children: [
                Icon(Icons.email_outlined, color: AppColors.warningColor),
                const SizedBox(width: 12),
                Text(
                  'تأكيد البريد الإلكتروني',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول. تحقق من صندوق الوارد أو الرسائل المهملة.',
              style: TextStyle(color: AppColors.greyDarkColor, fontSize: 14),
            ),
            actions: [
              // Cancel Button
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                ),
                onPressed: () => Get.back(),
                child: const Text('حسناً'),
              ),

              // Resend Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await credential.user!.sendEmailVerification();
                  Get.back();
                  Get.snackbar(
                    'تم الإرسال',
                    'تم إرسال رابط التحقق مرة أخرى',
                    backgroundColor: AppColors.greenColor,
                    colorText: AppColors.whiteColor,
                  );
                },
                child: const Text(
                  'إعادة إرسال',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
        return false;
      }

      // Check if user data exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        await _auth.signOut();
        Get.snackbar(
          'خطأ',
          'بيانات المستخدم غير موجودة. يرجى إنشاء حساب جديد.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Update email verification status in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
      });

      await _loadUserRole(credential.user!.uid);

      Get.snackbar(
        'نجح',
        'تم تسجيل الدخول بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      Get.snackbar('خطأ', message);
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Clear cached role
      if (_auth.currentUser != null) {
        try {
          await HiveService.deleteData('user_role_${_auth.currentUser!.uid}');
        } catch (e) {
          LoggerService.error('Failed to clear cached role', e, null);
        }
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear user data
      currentUser.value = null;
      userRole.value = '';
      isLoggedIn.value = false;

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.loginView);

      // Show success message with proper dark mode colors
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'نجح',
        'تم تسجيل الخروج بنجاح',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.green,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      LoggerService.info('User signed out successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Error during sign out', e, stackTrace);

      // Even if there's an error, clear local state and navigate
      currentUser.value = null;
      userRole.value = '';
      isLoggedIn.value = false;

      Get.offAllNamed(AppRoutes.loginView);

      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'تنبيه',
        'تم تسجيل الخروج محلياً، قد تحتاج للتحقق من الاتصال',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.orange,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      if (!ConnectivityService.instance.isConnected.value) {
        Get.snackbar('خطأ', 'يرجى التحقق من الاتصال بالإنترنت');
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('نجح', 'تم إرسال رابط إعادة تعيين كلمة المرور');
      return true;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      Get.snackbar('خطأ', message);
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ غير متوقع');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_auth.currentUser == null) return null;

      if (!ConnectivityService.instance.isConnected.value) {
        // Return cached data
        return {
          'uid': _auth.currentUser!.uid,
          'email': _auth.currentUser!.email,
          'name': _auth.currentUser!.displayName,
          'role': userRole.value,
        };
      }

      final doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? occupation,
  }) async {
    try {
      if (_auth.currentUser == null) return false;

      if (!ConnectivityService.instance.isConnected.value) {
        Get.snackbar('خطأ', 'يرجى التحقق من الاتصال بالإنترنت');
        return false;
      }

      Map<String, dynamic> updates = {};
      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser!.updateDisplayName(name);
      }
      if (phone != null) updates['phone'] = phone;
      if (occupation != null) updates['occupation'] = occupation;

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updates);

      Get.snackbar('نجح', 'تم تحديث البيانات بنجاح');
      return true;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث البيانات');
      return false;
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب من قبل المدير';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'فشل في الاتصال بالشبكة، يرجى التحقق من الإنترنت';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بهذا البريد مع طريقة تسجيل دخول مختلفة';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث لإجراء هذه العملية';
      case 'credential-already-in-use':
        return 'بيانات الاعتماد مستخدمة بالفعل';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'invalid-verification-id':
        return 'معرف التحقق غير صحيح';
      case 'missing-verification-code':
        return 'رمز التحقق مفقود';
      case 'missing-verification-id':
        return 'معرف التحقق مفقود';
      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح، يرجى المحاولة لاحقاً';
      case 'app-not-authorized':
        return 'التطبيق غير مخول لاستخدام Firebase Auth';
      case 'keychain-error':
        return 'خطأ في سلسلة المفاتيح';
      case 'internal-error':
        return 'خطأ داخلي، يرجى المحاولة مرة أخرى';
      case 'invalid-api-key':
        return 'مفتاح API غير صحيح';
      case 'app-not-installed':
        return 'التطبيق غير مثبت';
      case 'captcha-check-failed':
        return 'فشل في التحقق من الكابتشا';
      case 'code-expired':
        return 'انتهت صلاحية الرمز';
      case 'cordova-not-ready':
        return 'Cordova غير جاهز';
      case 'cors-unsupported':
        return 'CORS غير مدعوم';
      case 'dynamic-link-not-activated':
        return 'الرابط الديناميكي غير مفعل';
      case 'email-change-needs-verification':
        return 'تغيير البريد الإلكتروني يحتاج تحقق';
      case 'email-already-verified':
        return 'البريد الإلكتروني محقق بالفعل';
      case 'expired-action-code':
        return 'انتهت صلاحية رمز العملية';
      case 'cancelled-popup-request':
        return 'تم إلغاء طلب النافذة المنبثقة';
      case 'popup-blocked':
        return 'تم حظر النافذة المنبثقة';
      case 'popup-closed-by-user':
        return 'تم إغلاق النافذة المنبثقة من قبل المستخدم';
      case 'unauthorized-domain':
        return 'النطاق غير مخول';
      case 'invalid-action-code':
        return 'رمز العملية غير صحيح';
      case 'missing-action-code':
        return 'رمز العملية مفقود';
      case 'user-token-expired':
        return 'انتهت صلاحية رمز المستخدم';
      case 'invalid-user-token':
        return 'رمز المستخدم غير صحيح';
      case 'token-expired':
        return 'انتهت صلاحية الرمز';
      case 'user-mismatch':
        return 'عدم تطابق المستخدم';
      case 'provider-already-linked':
        return 'مقدم الخدمة مرتبط بالفعل';
      case 'no-such-provider':
        return 'لا يوجد مقدم خدمة بهذا الاسم';
      case 'invalid-provider-id':
        return 'معرف مقدم الخدمة غير صحيح';
      case 'web-storage-unsupported':
        return 'تخزين الويب غير مدعوم';
      default:
        return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
    }
  }

  List<String> _validateSignUpData(
    String email,
    String password,
    String name,
    int age,
  ) {
    List<String> errors = [];

    if (email.isEmpty) {
      errors.add('البريد الإلكتروني مطلوب');
    } else if (!GetUtils.isEmail(email)) {
      errors.add('البريد الإلكتروني غير صحيح');
    }

    if (password.isEmpty) {
      errors.add('كلمة المرور مطلوبة');
    } else if (password.length < 6) {
      errors.add('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    } else if (!_isPasswordStrong(password)) {
      errors.add('كلمة المرور يجب أن تحتوي على أحرف وأرقام');
    }

    if (name.isEmpty) {
      errors.add('الاسم مطلوب');
    } else if (name.length < 2) {
      errors.add('الاسم يجب أن يكون حرفين على الأقل');
    }

    if (age < 13 || age > 100) {
      errors.add('العمر يجب أن يكون بين 13 و 100 سنة');
    }

    return errors;
  }

  bool _isPasswordStrong(String password) {
    return password.contains(RegExp(r'[A-Za-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  void _showValidationErrors(List<String> errors) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('أخطاء في البيانات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              errors
                  .map(
                    (error) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.red)),
                          Expanded(child: Text(error)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('حسناً')),
        ],
      ),
    );
  }

  Future<void> refreshUserRole() async {
    if (_auth.currentUser != null) {
      // Clear cached role first
      try {
        await HiveService.deleteData('user_role_${_auth.currentUser!.uid}');
      } catch (e) {
        LoggerService.error('Failed to clear cached role', e, null);
      }

      // Force reload from Firestore
      await _loadUserRole(_auth.currentUser!.uid);

      // Force UI update
      update();
    }
  }

  // User role checks
  bool get isStudent => userRole.value == 'student';
  bool get isTherapist => userRole.value == 'therapist';
  bool get isAdmin => userRole.value == 'admin';
  bool get isSuperAdmin => userRole.value == 'superAdmin';

  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentUserName => _auth.currentUser?.displayName ?? '';
}
