import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/services/firebase_service.dart';
import 'package:quiz_app/core/services/logger_service.dart';
import 'package:quiz_app/core/services/student_rating_service.dart';

class StudentController extends GetxController {
  static StudentController get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final students = <StudentProfile>[].obs;
  final selectedStudent = Rxn<StudentProfile>();
  final selectedFilter = 'الكل'.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudentsFromFirestore();
  }

  Future<void> loadStudentsFromFirestore() async {
    try {
      isLoading.value = true;
      error.value = '';

      LoggerService.info('Starting student data loading process...');

      // Force connectivity check instead of relying on cached value
      final hasConnection =
          await ConnectivityService.instance.checkConnection();
      LoggerService.info('Connectivity check result: $hasConnection');

      if (!hasConnection) {
        LoggerService.warning('No internet connection detected');
        _initializeSampleData();
        error.value = 'لا يوجد اتصال بالإنترنت - يتم عرض البيانات التجريبية';
        return;
      }

      LoggerService.info(
        'Internet connection confirmed, proceeding with Firestore queries...',
      );

      // Get all users with student role
      QuerySnapshot usersQuery;
      try {
        LoggerService.info('Querying users collection for students...');
        usersQuery =
            await _firestore
                .collection('users')
                .where('role', isEqualTo: 'student')
                .get();
        LoggerService.info(
          'Student query successful. Found ${usersQuery.docs.length} student documents',
        );
      } catch (e) {
        // If the query fails, try to get all users and filter locally
        LoggerService.warning(
          'Failed to query students by role, trying all users: $e',
        );
        usersQuery = await _firestore.collection('users').get();
        LoggerService.info(
          'Fallback query successful. Found ${usersQuery.docs.length} total user documents',
        );
      }

      if (usersQuery.docs.isEmpty) {
        LoggerService.warning('No user documents found in Firestore');

        // Try to check if users collection exists at all
        try {
          final testQuery = await _firestore.collection('users').limit(1).get();
          if (testQuery.docs.isEmpty) {
            LoggerService.warning(
              'users collection appears to be completely empty',
            );
            error.value = 'لا توجد بيانات مستخدمين في قاعدة البيانات';
          } else {
            LoggerService.warning(
              'Users collection has data but no students found',
            );
            error.value = 'لا توجد حسابات طلاب في النظام';
          }
        } catch (e) {
          LoggerService.error('Failed to check users collection existence: $e');
          error.value = 'خطأ في الوصول إلى قاعدة البيانات: ${e.toString()}';
        }

        return;
      }

      final List<StudentProfile> loadedStudents = [];

      for (int i = 0; i < usersQuery.docs.length; i++) {
        final userDoc = usersQuery.docs[i];
        LoggerService.info(
          'Processing user ${i + 1}/${usersQuery.docs.length}: ${userDoc.id}',
        );

        final userData = userDoc.data() as Map<String, dynamic>;
        LoggerService.info('User data keys: ${userData.keys.toList()}');
        LoggerService.info('User role: ${userData['role']}');

        // Skip if not a student (in case we loaded all users)
        if (userData['role'] != 'student') {
          LoggerService.info('Skipping non-student user: ${userDoc.id}');
          continue;
        }

        LoggerService.info(
          'Processing student: ${userData['name'] ?? 'Unknown'}',
        );

        // Get assessments for this student
        QuerySnapshot assessmentsQuery;
        try {
          LoggerService.info(
            'Querying assessment_results for student ${userDoc.id}...',
          );
          assessmentsQuery =
              await _firestore
                  .collection('assessment_results')
                  .where('userId', isEqualTo: userDoc.id)
                  .orderBy('createdAt', descending: true)
                  .get();
          LoggerService.info(
            'Assessment query successful. Found ${assessmentsQuery.docs.length} assessments for student ${userDoc.id}',
          );
        } catch (e) {
          // If ordering fails, try without ordering
          LoggerService.warning(
            'Failed to order assessments for student ${userDoc.id}, trying without order: $e',
          );
          try {
            assessmentsQuery =
                await _firestore
                    .collection('assessment_results')
                    .where('userId', isEqualTo: userDoc.id)
                    .get();
            LoggerService.info(
              'Fallback assessment query successful. Found ${assessmentsQuery.docs.length} assessments',
            );
          } catch (e2) {
            LoggerService.error(
              'Failed to query assessments for student ${userDoc.id}: $e2',
            );
            // Create empty query result instead of failing completely
            assessmentsQuery =
                await _firestore
                    .collection('assessment_results')
                    .where('userId', isEqualTo: 'non_existent_user')
                    .get();
          }
        }

        final List<StudentAssessment> assessments = [];

        for (int j = 0; j < assessmentsQuery.docs.length; j++) {
          final assessmentDoc = assessmentsQuery.docs[j];
          LoggerService.info(
            'Processing assessment ${j + 1}/${assessmentsQuery.docs.length} for student ${userDoc.id}: ${assessmentDoc.id}',
          );

          final assessmentData = assessmentDoc.data() as Map<String, dynamic>;
          LoggerService.info(
            'Assessment data keys: ${assessmentData.keys.toList()}',
          );

          try {
            final assessment = StudentAssessment(
              id: assessmentDoc.id,
              assessmentId:
                  assessmentData['assessmentId'] ??
                  assessmentData['assessmentType'] ??
                  '',
              assessmentTitle:
                  assessmentData['assessmentTitle'] ??
                  assessmentData['assessmentName'] ??
                  'تقييم',
              totalScore:
                  (assessmentData['totalScore'] ?? assessmentData['score'] ?? 0)
                      .toDouble(),
              maxScore: (assessmentData['maxScore'] ?? 100).toDouble(),
              categoryScores: Map<String, int>.from(
                assessmentData['categoryScores'] ?? {},
              ),
              overallSeverity:
                  assessmentData['overallSeverity'] ??
                  assessmentData['severity'] ??
                  'غير محدد',
              completionDate:
                  assessmentData['createdAt'] != null
                      ? (assessmentData['createdAt'] as Timestamp).toDate()
                      : assessmentData['completedAt'] != null
                      ? (assessmentData['completedAt'] as Timestamp).toDate()
                      : DateTime.now(),
              timeSpentSeconds:
                  assessmentData['timeSpentSeconds'] ??
                  assessmentData['durationInSeconds'] ??
                  0,
              accuracyPercentage:
                  (assessmentData['accuracyPercentage'] ??
                          _calculateAccuracy(
                            assessmentData['totalScore'] ??
                                assessmentData['score'] ??
                                0,
                            assessmentData['maxScore'] ?? 100,
                          ))
                      .toDouble(),
            );

            assessments.add(assessment);
            LoggerService.info(
              'Successfully parsed assessment ${assessmentDoc.id}',
            );
          } catch (e) {
            LoggerService.error(
              'Error parsing assessment data for student ${userDoc.id}, assessment ${assessmentDoc.id}',
              e,
              null,
            );
          }
        }

        // Create student profile
        final student = StudentProfile(
          id: userDoc.id,
          name: userData['name'] ?? 'غير محدد',
          email: userData['email'] ?? '',
          registrationDate:
              userData['createdAt'] != null
                  ? (userData['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
          assessments: assessments,
          currentLevel: _calculateStudentLevel(assessments),
        );

        loadedStudents.add(student);
        LoggerService.info(
          'Successfully created student profile for ${student.name} with ${assessments.length} assessments',
        );
      }

      // Sort students by performance (average score descending)
      loadedStudents.sort(
        (a, b) => b.getAverageScore().compareTo(a.getAverageScore()),
      );

      students.value = loadedStudents;

      LoggerService.info(
        'Successfully loaded ${loadedStudents.length} students from Firestore',
      );

      // If no students found, show appropriate message
      if (loadedStudents.isEmpty) {
        error.value = 'لا توجد بيانات طلاب في قاعدة البيانات';
        LoggerService.warning(
          'No student profiles could be created from Firestore data',
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error loading students from Firestore',
        e,
        stackTrace,
      );
      error.value = 'فشل في تحميل بيانات الطلاب: ${e.toString()}';

      // Fallback to sample data if everything fails
      LoggerService.info('Falling back to sample data due to error');
      _initializeSampleData();
    } finally {
      isLoading.value = false;
      LoggerService.info('Student loading process completed');
    }
  }

  double _calculateAccuracy(dynamic score, dynamic maxScore) {
    final scoreValue = (score ?? 0).toDouble();
    final maxScoreValue = (maxScore ?? 100).toDouble();

    if (maxScoreValue == 0) return 0.0;
    return (scoreValue / maxScoreValue) * 100;
  }

  String _calculateStudentLevel(List<StudentAssessment> assessments) {
    if (assessments.isEmpty) return 'مبتدئ';

    final totalAssessments = assessments.length;
    final averageScore =
        assessments.map((a) => a.accuracyPercentage).reduce((a, b) => a + b) /
        totalAssessments;

    if (totalAssessments >= 10 && averageScore >= 90) return 'خبير';
    if (totalAssessments >= 5 && averageScore >= 80) return 'متقدم';
    if (totalAssessments >= 3 && averageScore >= 70) return 'متوسط';
    return 'مبتدئ';
  }

  Future<void> refreshStudents() async {
    LoggerService.info('Refresh requested for students');
    await loadStudentsFromFirestore();
  }

  Future<void> forceRefresh() async {
    LoggerService.info('Force refresh requested for students');
    await loadStudentsFromFirestore();
  }

  Future<Map<String, dynamic>> diagnosticInfo() async {
    try {
      LoggerService.info('Running student diagnostic...');

      final isConnected = await ConnectivityService.instance.checkConnection();

      // Check users collection for students
      final studentsQuery =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'student')
              .limit(5)
              .get();

      // Check assessment_results collection
      final assessmentResultsQuery =
          await _firestore.collection('assessment_results').limit(5).get();

      final diagnostics = {
        'isConnected': isConnected,
        'studentsInFirestore': studentsQuery.docs.length,
        'assessmentResultsInFirestore': assessmentResultsQuery.docs.length,
        'loadedStudentsCount': students.length,
        'sampleStudentData':
            studentsQuery.docs.isNotEmpty
                ? studentsQuery.docs.first.data()
                : null,
        'sampleAssessmentData':
            assessmentResultsQuery.docs.isNotEmpty
                ? assessmentResultsQuery.docs.first.data()
                : null,
        'timestamp': DateTime.now().toIso8601String(),
      };

      LoggerService.info('Student diagnostics: $diagnostics');
      return diagnostics;
    } catch (e, stackTrace) {
      LoggerService.error('Error running student diagnostics', e, stackTrace);
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  void addStudent(String name, String email) {
    final newStudent = StudentRatingService.createStudentProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );
    students.add(newStudent);
    update();
  }

  void addAssessmentToStudent(
    StudentProfile student,
    StudentAssessment assessment,
  ) {
    final updatedStudent = StudentRatingService.addAssessmentToStudent(
      student,
      assessment,
    );

    final index = students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      students[index] = updatedStudent;
      selectedStudent.value = updatedStudent;
      students.refresh();
    }
  }

  StudentReport getStudentReport(StudentProfile student) {
    return StudentRatingService.generateStudentReport(student);
  }

  double getStudentGrade(StudentProfile student) {
    final report = StudentRatingService.generateStudentReport(student);
    return StudentRatingService.calculateStudentGrade(report.statistics);
  }

  String classifyStudent(StudentProfile student) {
    final report = StudentRatingService.generateStudentReport(student);
    return StudentRatingService.classifyStudent(report.statistics);
  }

  List<StudentProfile> getTopStudents({int limit = 10}) {
    // Return top students sorted by average score
    final sortedStudents = List<StudentProfile>.from(students)
      ..sort((a, b) => b.getAverageScore().compareTo(a.getAverageScore()));

    return sortedStudents.take(limit).toList();
  }

  Map<String, dynamic> compareStudents(
    StudentProfile student1,
    StudentProfile student2,
  ) {
    return StudentRatingService.compareStudents(student1, student2);
  }

  Map<String, dynamic> analyzePerformancePattern(StudentProfile student) {
    return StudentRatingService.analyzePerformancePattern(student);
  }

  List<StudentProfile> getFilteredStudents(String level) {
    if (level == 'الكل') {
      return students;
    }
    return students.where((s) => s.currentLevel == level).toList();
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  void selectStudent(StudentProfile student) {
    selectedStudent.value = student;
    update();
  }

  void removeStudent(StudentProfile student) {
    students.removeWhere((s) => s.id == student.id);
    if (selectedStudent.value?.id == student.id) {
      selectedStudent.value = null;
    }
    students.refresh();
  }

  void updateStudentGrade(StudentProfile student, double newGrade) {
    update();
  }

  void _initializeSampleData() {
    // Don't add sample data - show empty state instead
    students.clear();
    error.value = 'لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة محلياً';
  }
}

Future<void> testFirestoreConnection() async {
  try {
    LoggerService.info('Testing Firestore connection for students...');

    // Test users collection for students
    final studentsTest =
        await FirebaseService.firestore!
            .collection('users')
            .where('role', isEqualTo: 'student')
            .limit(5)
            .get();
    LoggerService.info('Students found: ${studentsTest.docs.length}');

    // Test assessment_results collection
    final assessmentTest =
        await FirebaseService.firestore!
            .collection('assessment_results')
            .limit(5)
            .get();
    LoggerService.info(
      'Assessment results found: ${assessmentTest.docs.length}',
    );

    // Show sample data if available
    String sampleInfo = '';
    if (studentsTest.docs.isNotEmpty) {
      final sampleStudent = studentsTest.docs.first.data();
      sampleInfo += '\nطالب عينة: ${sampleStudent['name'] ?? 'غير محدد'}';
    }

    if (assessmentTest.docs.isNotEmpty) {
      final sampleAssessment = assessmentTest.docs.first.data();
      sampleInfo +=
          '\nتقييم عينة: ${sampleAssessment['assessmentTitle'] ?? sampleAssessment['assessmentName'] ?? 'غير محدد'}';
    }

    Get.snackbar(
      'اختبار بيانات الطلاب',
      'الطلاب: ${studentsTest.docs.length}\nالتقييمات: ${assessmentTest.docs.length}$sampleInfo',
      duration: const Duration(seconds: 5),
    );
  } catch (e, stackTrace) {
    LoggerService.error('Student data test failed', e, stackTrace);
    Get.snackbar(
      'خطأ في اختبار البيانات',
      'فشل في اختبار بيانات الطلاب: ${e.toString()}',
      duration: const Duration(seconds: 5),
    );
  }
}

Future<void> createSampleDataForTesting() async {
  try {
    LoggerService.info('Creating sample data for testing...');

    // This method would create sample users and assessments in Firestore
    // Only for development/testing purposes

    Get.snackbar(
      'إنشاء بيانات تجريبية',
      'هذه الميزة متاحة فقط في وضع التطوير',
      duration: const Duration(seconds: 3),
    );
  } catch (e) {
    LoggerService.error('Failed to create sample data', e);
  }
}
