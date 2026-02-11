import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
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

      // Always try to load from Firestore first, regardless of connectivity status
      try {
        // Get all users with student role
        final usersQuery =
            await _firestore
                .collection('users')
                .where('role', isEqualTo: 'student')
                .get();

        final List<StudentProfile> loadedStudents = [];

        for (final userDoc in usersQuery.docs) {
          final userData = userDoc.data();

          // Get assessments for this student
          final assessmentsQuery =
              await _firestore
                  .collection('assessment_results')
                  .where('userId', isEqualTo: userDoc.id)
                  .orderBy('createdAt', descending: true)
                  .get();

          final List<StudentAssessment> assessments = [];

          for (final assessmentDoc in assessmentsQuery.docs) {
            final assessmentData = assessmentDoc.data();

            try {
              final assessment = StudentAssessment(
                id: assessmentDoc.id,
                assessmentId: assessmentData['assessmentId'] ?? '',
                assessmentTitle: assessmentData['assessmentTitle'] ?? 'تقييم',
                totalScore: (assessmentData['totalScore'] ?? 0).toDouble(),
                maxScore: (assessmentData['maxScore'] ?? 100).toDouble(),
                categoryScores: Map<String, int>.from(
                  assessmentData['categoryScores'] ?? {},
                ),
                overallSeverity:
                    assessmentData['overallSeverity'] ?? 'غير محدد',
                completionDate:
                    assessmentData['createdAt'] != null
                        ? (assessmentData['createdAt'] as Timestamp).toDate()
                        : DateTime.now(),
                timeSpentSeconds: assessmentData['timeSpentSeconds'] ?? 0,
                accuracyPercentage:
                    (assessmentData['accuracyPercentage'] ?? 0.0).toDouble(),
              );

              assessments.add(assessment);
            } catch (e) {
              LoggerService.error('Error parsing assessment data', e, null);
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
        }

        // Sort students by performance (average score descending)
        loadedStudents.sort(
          (a, b) => b.getAverageScore().compareTo(a.getAverageScore()),
        );

        students.value = loadedStudents;

        LoggerService.info(
          'Loaded ${loadedStudents.length} students from Firestore',
        );
      } catch (firestoreError) {
        // If Firestore fails, try to show sample data with appropriate message
        LoggerService.error(
          'Error loading students from Firestore',
          firestoreError,
          null,
        );

        // Check if it's a connectivity issue
        final hasConnection =
            await ConnectivityService.instance.checkConnection();
        if (!hasConnection) {
          _initializeSampleData();
          error.value = 'لا يوجد اتصال بالإنترنت - يتم عرض البيانات التجريبية';
        } else {
          error.value =
              'فشل في تحميل بيانات الطلاب: ${firestoreError.toString()}';
        }
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error loading students from Firestore',
        e,
        stackTrace,
      );
      error.value = 'فشل في تحميل بيانات الطلاب: ${e.toString()}';

      // Fallback to sample data if everything fails
      _initializeSampleData();
    } finally {
      isLoading.value = false;
    }
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
    await loadStudentsFromFirestore();
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
    // Keep sample data as fallback
    final student1 = StudentRatingService.createStudentProfile(
      id: 'sample_1',
      name: 'أحمد عماد',
      email: 'muhammad@example.com',
    );

    final student2 = StudentRatingService.createStudentProfile(
      id: 'sample_2',
      name: 'معاذ صلاح',
      email: 'moez@example.com',
    );

    final student3 = StudentRatingService.createStudentProfile(
      id: 'sample_3',
      name: 'سارة كمال',
      email: 'sarah@example.com',
    );

    students.addAll([student1, student2, student3]);
  }
}
