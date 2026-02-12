import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class UserAssessmentDetailsController extends GetxController {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserAssessmentDetailsController(this.userId);

  // Observable variables
  var isLoading = false.obs;
  var error = ''.obs;
  var userInfo = <String, dynamic>{}.obs;
  var recentAssessments = <Map<String, dynamic>>[].obs;
  var totalAssessments = 0.obs;
  var averageScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load user info and assessments in parallel
      await Future.wait([_loadUserInfo(), _loadUserAssessments()]);
    } catch (e, stackTrace) {
      LoggerService.error('Error loading user details', e, stackTrace);
      error.value = 'فشل في تحميل بيانات المستخدم: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        userInfo.value = userDoc.data() ?? {};
      } else {
        throw Exception('المستخدم غير موجود');
      }
    } catch (e) {
      LoggerService.error('Error loading user info', e);
      rethrow;
    }
  }

  Future<void> _loadUserAssessments() async {
    try {
      LoggerService.info('Loading assessments for user: $userId');

      // Try to load from user's subcollection first (better organization)
      QuerySnapshot? assessmentsQuery;
      bool fromSubcollection = false;

      try {
        assessmentsQuery =
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('assessments')
                .orderBy('createdAt', descending: true)
                .limit(20)
                .get();

        if (assessmentsQuery.docs.isNotEmpty) {
          fromSubcollection = true;
          LoggerService.info(
            'Loaded ${assessmentsQuery.docs.length} assessments from subcollection',
          );
        }
      } catch (e) {
        LoggerService.info(
          'Subcollection not available, trying main collection: $e',
        );
      }

      // Fallback to main collection if subcollection is empty or doesn't exist
      if (assessmentsQuery == null || assessmentsQuery.docs.isEmpty) {
        try {
          assessmentsQuery =
              await _firestore
                  .collection('assessment_results')
                  .where('userId', isEqualTo: userId)
                  .orderBy('createdAt', descending: true)
                  .limit(20)
                  .get();

          LoggerService.info(
            'Loaded ${assessmentsQuery.docs.length} assessments from main collection',
          );
        } catch (e) {
          LoggerService.warning(
            'Failed to order by createdAt, trying timestamp: $e',
          );

          assessmentsQuery =
              await _firestore
                  .collection('assessment_results')
                  .where('userId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .get();

          LoggerService.info(
            'Loaded ${assessmentsQuery.docs.length} assessments ordered by timestamp',
          );
        }
      }

      final assessmentsList = <Map<String, dynamic>>[];
      final seenIds = <String>{};
      double totalScore = 0;
      int validScores = 0;

      for (final doc in assessmentsQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Prevent duplicates by checking document ID
        if (seenIds.contains(doc.id)) {
          LoggerService.warning('Duplicate assessment found: ${doc.id}');
          continue;
        }
        seenIds.add(doc.id);

        // Parse date
        DateTime? createdAt;
        try {
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.parse(data['createdAt']);
            }
          } else if (data['timestamp'] != null &&
              data['timestamp'] is Timestamp) {
            createdAt = (data['timestamp'] as Timestamp).toDate();
          }
        } catch (e) {
          LoggerService.warning(
            'Error parsing date for assessment ${doc.id}: $e',
          );
          createdAt = DateTime.now();
        }

        final assessment = {
          'id': doc.id,
          'assessmentName':
              data['assessmentName'] ??
              data['assessmentTitle'] ??
              data['title'] ??
              'اختبار غير محدد',
          'assessmentType': data['assessmentType'] ?? data['type'] ?? 'unknown',
          'score': (data['score'] ?? data['totalScore'] ?? 0).toInt(),
          'maxScore': (data['maxScore'] ?? 100).toInt(),
          'date': createdAt != null ? _formatDate(createdAt) : 'غير محدد',
          'severity': data['severity'] ?? data['overallSeverity'] ?? 'غير محدد',
          'completedAt': createdAt,
          'interpretation': data['interpretation'] ?? 'لا توجد تفسيرات',
          'recommendations': List<String>.from(data['recommendations'] ?? []),
          'categoryScores': Map<String, dynamic>.from(
            data['categoryScores'] ?? {},
          ),
          'durationInSeconds': (data['durationInSeconds'] ?? 0).toInt(),
          'fromSubcollection': fromSubcollection,
        };

        assessmentsList.add(assessment);

        // Calculate average score
        final score = assessment['score'] as int;
        final maxScore = assessment['maxScore'] as int;
        if (maxScore > 0) {
          totalScore += (score / maxScore) * 100;
          validScores++;
        }
      }

      // Sort by date if not already sorted
      assessmentsList.sort((a, b) {
        final dateA = a['completedAt'] as DateTime?;
        final dateB = b['completedAt'] as DateTime?;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      recentAssessments.value = assessmentsList;
      totalAssessments.value = assessmentsList.length;
      averageScore.value = validScores > 0 ? totalScore / validScores : 0.0;

      LoggerService.info(
        'Successfully loaded ${assessmentsList.length} unique assessments',
      );
      LoggerService.info(
        'Average score: ${averageScore.value.toStringAsFixed(1)}%',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error loading user assessments', e, stackTrace);
      rethrow;
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'غير محدد';

      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'غير محدد';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'اليوم';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
      } else {
        final years = (difference.inDays / 365).floor();
        return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
      }
    } catch (e) {
      return 'غير محدد';
    }
  }

  String getFormattedJoinDate() {
    try {
      final createdAt = userInfo['createdAt'];
      if (createdAt == null) return 'غير محدد';

      DateTime date;
      if (createdAt is Timestamp) {
        date = createdAt.toDate();
      } else if (createdAt is String) {
        date = DateTime.parse(createdAt);
      } else {
        return 'غير محدد';
      }

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  String getLastAssessmentDate() {
    if (recentAssessments.isEmpty) return 'لا يوجد';

    try {
      final lastAssessment = recentAssessments.first;
      final completedAt = lastAssessment['completedAt'];

      if (completedAt == null) return 'غير محدد';

      DateTime date;
      if (completedAt is Timestamp) {
        date = completedAt.toDate();
      } else if (completedAt is String) {
        date = DateTime.parse(completedAt);
      } else {
        return 'غير محدد';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'اليوم';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} أيام';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return 'غير محدد';
    }
  }

  // Get user performance trend (for future chart implementation)
  List<Map<String, dynamic>> getPerformanceTrend() {
    final trend = <Map<String, dynamic>>[];

    for (int i = 0; i < recentAssessments.length && i < 5; i++) {
      final assessment = recentAssessments[i];
      final score = assessment['score'] ?? 0;
      final maxScore = assessment['maxScore'] ?? 100;
      final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0;

      trend.add({
        'date': assessment['date'],
        'score': percentage,
        'assessmentName': assessment['assessmentName'],
      });
    }

    return trend.reversed.toList(); // Reverse to show chronological order
  }

  // Get assessment distribution by severity
  Map<String, int> getAssessmentDistribution() {
    final distribution = <String, int>{
      'منخفض': 0,
      'متوسط': 0,
      'مرتفع': 0,
      'شديد': 0,
    };

    for (final assessment in recentAssessments) {
      final severity = assessment['severity'] ?? 'غير محدد';
      if (distribution.containsKey(severity)) {
        distribution[severity] = distribution[severity]! + 1;
      }
    }

    return distribution;
  }

  // Refresh data
  @override
  Future<void> refresh() async {
    await loadUserDetails();
  }
}
