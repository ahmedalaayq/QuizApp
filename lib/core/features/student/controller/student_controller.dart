import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:quiz_app/core/models/student_model.dart';
import 'package:quiz_app/core/services/student_rating_service.dart';

class StudentController extends GetxController {
  static StudentController get to => Get.find();

  final students = <StudentProfile>[].obs;
  final selectedStudent = Rxn<StudentProfile>();
  final selectedFilter = 'الكل'.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSampleData();
  }

  void addStudent(String name, String email) {
    final newStudent = StudentRatingService.createStudentProfile(
      id: const Uuid().v4(),
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
    return StudentRatingService.getTopStudents(students, limit: limit);
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
    final student1 = StudentRatingService.createStudentProfile(
      id: const Uuid().v4(),
      name: 'محمد أحمد',
      email: 'muhammad@example.com',
    );

    final student2 = StudentRatingService.createStudentProfile(
      id: const Uuid().v4(),
      name: 'فاطمة خالد',
      email: 'fatima@example.com',
    );

    final student3 = StudentRatingService.createStudentProfile(
      id: const Uuid().v4(),
      name: 'سارة علي',
      email: 'sarah@example.com',
    );

    var updatedStudent1 = StudentRatingService.addAssessmentToStudent(
      student1,
      StudentAssessment(
        id: const Uuid().v4(),
        assessmentId: 'dass-1',
        assessmentTitle: 'DASS-21',
        totalScore: 78,
        maxScore: 84,
        categoryScores: {'depression': 25, 'anxiety': 26, 'stress': 27},
        overallSeverity: 'خفيف',
        completionDate: DateTime.now().subtract(const Duration(days: 5)),
        timeSpentSeconds: 600,
        accuracyPercentage: 92.9,
      ),
    );
    updatedStudent1 = StudentRatingService.addAssessmentToStudent(
      updatedStudent1,
      StudentAssessment(
        id: const Uuid().v4(),
        assessmentId: 'dass-2',
        assessmentTitle: 'DASS-21',
        totalScore: 82,
        maxScore: 84,
        categoryScores: {'depression': 27, 'anxiety': 28, 'stress': 27},
        overallSeverity: 'طبيعي',
        completionDate: DateTime.now().subtract(const Duration(days: 2)),
        timeSpentSeconds: 550,
        accuracyPercentage: 97.6,
      ),
    );
    updatedStudent1 = StudentRatingService.addAssessmentToStudent(
      updatedStudent1,
      StudentAssessment(
        id: const Uuid().v4(),
        assessmentId: 'assq-1',
        assessmentTitle: 'ASSQ',
        totalScore: 7,
        maxScore: 10,
        categoryScores: {'social': 3, 'behavior': 2, 'sensory': 2},
        overallSeverity: 'خفيف',
        completionDate: DateTime.now(),
        timeSpentSeconds: 400,
        accuracyPercentage: 70.0,
      ),
    );

    var updatedStudent2 = StudentRatingService.addAssessmentToStudent(
      student2,
      StudentAssessment(
        id: const Uuid().v4(),
        assessmentId: 'dass-3',
        assessmentTitle: 'DASS-21',
        totalScore: 85,
        maxScore: 84,
        categoryScores: {'depression': 28, 'anxiety': 29, 'stress': 28},
        overallSeverity: 'طبيعي',
        completionDate: DateTime.now().subtract(const Duration(days: 3)),
        timeSpentSeconds: 620,
        accuracyPercentage: 100.0,
      ),
    );
    updatedStudent2 = StudentRatingService.addAssessmentToStudent(
      updatedStudent2,
      StudentAssessment(
        id: const Uuid().v4(),
        assessmentId: 'assq-2',
        assessmentTitle: 'ASSQ',
        totalScore: 8,
        maxScore: 10,
        categoryScores: {'social': 3, 'behavior': 2, 'sensory': 3},
        overallSeverity: 'طبيعي',
        completionDate: DateTime.now(),
        timeSpentSeconds: 420,
        accuracyPercentage: 80.0,
      ),
    );

    var updatedStudent3 = StudentRatingService.addAssessmentToStudent(
      student3,
      StudentAssessment(
        id: const Uuid().v4(),
        assessmentId: 'dass-4',
        assessmentTitle: 'DASS-21',
        totalScore: 72,
        maxScore: 84,
        categoryScores: {'depression': 24, 'anxiety': 24, 'stress': 24},
        overallSeverity: 'متوسط',
        completionDate: DateTime.now(),
        timeSpentSeconds: 680,
        accuracyPercentage: 85.7,
      ),
    );

    students.addAll([updatedStudent1, updatedStudent2, updatedStudent3]);
  }
}
