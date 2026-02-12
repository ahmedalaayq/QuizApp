import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/core/database/hive_service.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:quiz_app/core/services/pdf_service.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class StatisticsController extends GetxController {
  final RxList<AssessmentHistory> assessments = <AssessmentHistory>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalAssessments = 0.obs;
  final RxDouble averageScore = 0.0.obs;
  final RxString mostCommonSeverity = ''.obs;
  final RxString error = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  // Get assessments stream for real-time updates
  Stream<QuerySnapshot> getAssessmentsStream() {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    Query query = _firestore.collection('assessment_results');
    final userRole = _authService.userRole.value;

    // For students, only show their own assessments
    if (userRole == 'student') {
      query = query.where('userId', isEqualTo: currentUser.uid);
    }

    // Try to order by createdAt, fallback to no ordering
    try {
      return query
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots();
    } catch (e) {
      LoggerService.warning('Failed to order stream by createdAt: $e');
      try {
        return query
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots();
      } catch (e2) {
        LoggerService.warning('Failed to order stream by timestamp: $e2');
        return query.limit(100).snapshots();
      }
    }
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    error.value = '';

    try {
      LoggerService.info('Starting statistics loading process...');

      // Force connectivity check instead of relying on cached value
      final hasConnection =
          await ConnectivityService.instance.checkConnection();
      LoggerService.info('Connectivity check result: $hasConnection');

      if (hasConnection) {
        LoggerService.info('Attempting to load from Firestore...');
        await _loadFromFirestore();

        // If Firestore loading was successful but no data, show empty state
        if (assessments.isEmpty) {
          LoggerService.info('No data from Firestore');
          error.value = 'لا توجد بيانات تقييمات في قاعدة البيانات';
        }
      } else {
        LoggerService.warning(
          'No internet connection, loading from local storage',
        );
        _loadFromLocal();
        if (error.value.isEmpty && assessments.isNotEmpty) {
          error.value =
              'لا يوجد اتصال بالإنترنت - يتم عرض البيانات المحفوظة محلياً';
        }
      }

      calculateStatistics();
      LoggerService.info(
        'Statistics calculation completed. Total assessments: ${assessments.length}',
      );

      // Log data source for debugging
      if (assessments.isNotEmpty) {
        LoggerService.info('Sample assessment data:');
        final sample = assessments.first;
        LoggerService.info('- ID: ${sample.id}');
        LoggerService.info('- User: ${sample.userName}');
        LoggerService.info('- Type: ${sample.assessmentType}');
        LoggerService.info('- Date: ${sample.completionDate}');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error loading statistics', e, stackTrace);
      error.value = 'فشل في تحميل الإحصائيات: ${e.toString()}';

      // Fallback to local data only if network error
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        try {
          LoggerService.info('Attempting fallback to local data...');
          _loadFromLocal();
          calculateStatistics();
          if (assessments.isNotEmpty) {
            error.value =
                'تم تحميل البيانات المحفوظة محلياً - قد لا تكون محدثة';
          }
        } catch (localError) {
          LoggerService.error('Error loading local statistics', localError);
          error.value = 'فشل في تحميل البيانات: ${localError.toString()}';
        }
      }
    } finally {
      isLoading.value = false;
      LoggerService.info('Statistics loading process completed');
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      LoggerService.info('Starting Firestore data loading...');

      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      LoggerService.info('Current user ID: ${currentUser.uid}');

      Query query = _firestore.collection('assessment_results');
      LoggerService.info(
        'Base query created for collection: assessment_results',
      );

      // For students, only show their own assessments
      final userRole = _authService.userRole.value;
      LoggerService.info('User role: $userRole');

      if (userRole == 'student') {
        query = query.where('userId', isEqualTo: currentUser.uid);
        LoggerService.info(
          'Applied student filter for userId: ${currentUser.uid}',
        );
      } else {
        LoggerService.info('Admin/Therapist access - loading all assessments');
      }

      // Try different ordering strategies
      QuerySnapshot? querySnapshot;

      // Strategy 1: Order by createdAt
      try {
        final orderedQuery = query
            .orderBy('createdAt', descending: true)
            .limit(100);
        querySnapshot = await orderedQuery.get();
        LoggerService.info('Successfully ordered by createdAt');
      } catch (e) {
        LoggerService.warning('Failed to order by createdAt: $e');

        // Strategy 2: Order by timestamp
        try {
          final orderedQuery = query
              .orderBy('timestamp', descending: true)
              .limit(100);
          querySnapshot = await orderedQuery.get();
          LoggerService.info('Successfully ordered by timestamp');
        } catch (e2) {
          LoggerService.warning('Failed to order by timestamp: $e2');

          // Strategy 3: No ordering, just limit
          try {
            final limitedQuery = query.limit(100);
            querySnapshot = await limitedQuery.get();
            LoggerService.info('Loaded without ordering');
          } catch (e3) {
            LoggerService.error('All query strategies failed: $e3');
            throw e3;
          }
        }
      }

      LoggerService.info(
        'Query executed successfully. Documents found: ${querySnapshot.docs.length}',
      );

      if (querySnapshot.docs.isEmpty) {
        LoggerService.warning(
          'No documents found in assessment_results collection',
        );
        assessments.value = [];
        return;
      }

      final List<AssessmentHistory> firestoreAssessments = [];
      final Set<String> seenIds =
          <String>{}; // Track seen IDs to prevent duplicates

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        LoggerService.info(
          'Processing document ${i + 1}/${querySnapshot.docs.length}: ${doc.id}',
        );

        try {
          final data = doc.data() as Map<String, dynamic>;
          LoggerService.info('Document data keys: ${data.keys.toList()}');

          // Check for duplicates using assessment ID or document ID
          final assessmentId = data['id'] ?? doc.id;
          if (seenIds.contains(assessmentId)) {
            LoggerService.warning(
              'Duplicate assessment found with ID: $assessmentId, skipping',
            );
            continue;
          }
          seenIds.add(assessmentId);

          // Enhanced data parsing with multiple fallbacks
          DateTime completionDate;
          try {
            if (data['createdAt'] != null) {
              completionDate = (data['createdAt'] as Timestamp).toDate();
            } else if (data['timestamp'] != null) {
              completionDate = (data['timestamp'] as Timestamp).toDate();
            } else if (data['completedAt'] != null) {
              completionDate = (data['completedAt'] as Timestamp).toDate();
            } else {
              completionDate = DateTime.now();
            }
          } catch (e) {
            LoggerService.warning('Error parsing date for doc ${doc.id}: $e');
            completionDate = DateTime.now();
          }

          // Convert Firestore data to AssessmentHistory
          final assessment = AssessmentHistory(
            id: doc.id,
            assessmentType:
                data['assessmentType'] ??
                data['assessmentId'] ??
                data['type'] ??
                'unknown',
            assessmentTitle:
                data['assessmentName'] ??
                data['assessmentTitle'] ??
                data['title'] ??
                'اختبار غير محدد',
            completionDate: completionDate,
            totalScore: (data['score'] ?? data['totalScore'] ?? 0).toInt(),
            categoryScores: Map<String, dynamic>.from(
              data['categoryScores'] ?? data['scores'] ?? {},
            ),
            overallSeverity:
                data['severity'] ??
                data['overallSeverity'] ??
                data['level'] ??
                'غير محدد',
            interpretation:
                data['interpretation'] ??
                data['result'] ??
                'لا توجد تفسيرات متاحة',
            recommendations: List<String>.from(
              data['recommendations'] ?? data['suggestions'] ?? [],
            ),
            durationInSeconds:
                (data['durationInSeconds'] ?? data['duration'] ?? 0).toInt(),
            userId: data['userId'] ?? data['user_id'],
            userName: await _getUserName(data),
          );

          firestoreAssessments.add(assessment);
          LoggerService.info('Successfully parsed document ${doc.id}');
        } catch (e) {
          LoggerService.warning(
            'Error parsing assessment document ${doc.id}: $e',
          );
        }
      }

      // Sort by completion date if not already sorted
      firestoreAssessments.sort(
        (a, b) => b.completionDate.compareTo(a.completionDate),
      );

      assessments.value = firestoreAssessments;
      LoggerService.info(
        'Successfully loaded ${firestoreAssessments.length} assessments from Firestore for role: $userRole',
      );

      if (firestoreAssessments.isEmpty) {
        LoggerService.warning(
          'No valid assessments could be parsed from Firestore documents',
        );
        error.value =
            'تم العثور على بيانات ولكن لا يمكن تحليلها - تحقق من بنية البيانات';
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error loading from Firestore', e, stackTrace);
      rethrow;
    }
  }

  void _loadFromLocal() {
    try {
      final localAssessments = HiveService.getAllResults();
      assessments.value = localAssessments;
      LoggerService.info(
        'Loaded ${localAssessments.length} assessments from local storage',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error loading from local storage', e, stackTrace);
      assessments.value = [];
    }
  }

  void calculateStatistics() {
    if (assessments.isEmpty) {
      totalAssessments.value = 0;
      averageScore.value = 0.0;
      mostCommonSeverity.value = '';
      return;
    }

    totalAssessments.value = assessments.length;

    // Calculate average score
    final total = assessments.fold<int>(
      0,
      (accumulator, item) => accumulator + item.totalScore,
    );
    averageScore.value = total / assessments.length;

    // Find most common severity
    final severityMap = <String, int>{};
    for (var assessment in assessments) {
      final severity = assessment.overallSeverity;
      severityMap[severity] = (severityMap[severity] ?? 0) + 1;
    }

    if (severityMap.isNotEmpty) {
      mostCommonSeverity.value =
          severityMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }
  }

  // Helper method to get user name with fallbacks
  Future<String> _getUserName(Map<String, dynamic> data) async {
    // Try to get name from assessment data first
    String userName =
        data['userName'] ?? data['user_name'] ?? data['name'] ?? '';

    // If no name found and we have userId, fetch from users collection
    if (userName.isEmpty && data['userId'] != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(data['userId']).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userName =
              userData['name'] ??
              userData['displayName'] ??
              userData['email']?.split('@')[0] ??
              '';
        }
      } catch (e) {
        LoggerService.warning(
          'Could not fetch user name for ${data['userId']}: $e',
        );
      }
    }

    return userName.isNotEmpty ? userName : 'مستخدم غير معروف';
  }

  Future<void> exportReport() async {
    if (assessments.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد بيانات لتصديرها',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bool isDark = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900]!.withOpacity(0.95) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Title
              Text(
                'تصدير التقرير',
                style: AppTextStyles.cairo18w600.copyWith(
                  color: isDark ? Colors.white : AppColors.greyDarkColor,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),

              const SizedBox(height: 12),

              /// Options
              _buildSheetOption(
                icon: Icons.picture_as_pdf,
                iconColor: Colors.redAccent,
                title: 'تصدير تقرير شامل',
                subtitle: 'احصل على نسخة PDF كاملة لجميع التقييمات',
                onTap: () async {
                  Get.back();
                  await PdfService.exportFullReport(assessments);
                },
              ),
              const SizedBox(height: 12),
              _buildSheetOption(
                icon: Icons.print,
                iconColor: Colors.blueAccent,
                title: 'طباعة آخر تقرير',
                subtitle: 'اطبع آخر تقييم تم حفظه',
                onTap: () async {
                  Get.back();
                  if (assessments.isNotEmpty) {
                    await PdfService.printReport(assessments.first);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isDark
                            ? Colors.white12
                            : AppColors.greyLightColor.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.cairo16w600.copyWith(
                      color: isDark ? Colors.redAccent : AppColors.redColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void refresh() {
    loadStatistics();
  }

  Future<void> forceRefresh() async {
    LoggerService.info('Force refresh requested for statistics');
    await loadStatistics();
  }

  // Add method to clean duplicate assessments
  Future<void> cleanDuplicateAssessments() async {
    try {
      LoggerService.info('Starting duplicate assessment cleanup...');

      final assessmentsQuery =
          await _firestore.collection('assessment_results').get();

      final Map<String, List<DocumentSnapshot>> assessmentGroups = {};

      // Group assessments by their ID
      for (final doc in assessmentsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final assessmentId = data['id'] ?? doc.id;

        if (!assessmentGroups.containsKey(assessmentId)) {
          assessmentGroups[assessmentId] = [];
        }
        assessmentGroups[assessmentId]!.add(doc);
      }

      int duplicatesFound = 0;
      int duplicatesDeleted = 0;

      // Find and delete duplicates
      for (final entry in assessmentGroups.entries) {
        final docs = entry.value;
        if (docs.length > 1) {
          duplicatesFound += docs.length - 1;
          LoggerService.info(
            'Found ${docs.length} duplicates for assessment ID: ${entry.key}',
          );

          // Keep the first document, delete the rest
          for (int i = 1; i < docs.length; i++) {
            try {
              await docs[i].reference.delete();
              duplicatesDeleted++;
              LoggerService.info('Deleted duplicate document: ${docs[i].id}');
            } catch (e) {
              LoggerService.error(
                'Failed to delete duplicate ${docs[i].id}: $e',
              );
            }
          }
        }
      }

      LoggerService.info(
        'Cleanup completed. Found: $duplicatesFound, Deleted: $duplicatesDeleted',
      );

      Get.snackbar(
        'تنظيف البيانات',
        'تم العثور على $duplicatesFound تكرار وحذف $duplicatesDeleted منها',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Refresh data after cleanup
      await forceRefresh();
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error cleaning duplicate assessments',
        e,
        stackTrace,
      );
      Get.snackbar(
        'خطأ',
        'فشل في تنظيف البيانات المكررة: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

Widget _buildSheetOption({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Material(
    color: Get.isDarkMode ? AppColors.greyDarkColor : AppColors.whiteColor,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cairo16w600.copyWith(
                      color:
                          Get.isDarkMode
                              ? AppColors.whiteColor
                              : AppColors.greyDarkColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    ),
  );
}
