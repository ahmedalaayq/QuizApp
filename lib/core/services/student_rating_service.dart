import 'package:quiz_app/core/models/student_model.dart';

/// خدمة إدارة وتقييم الطلاب
class StudentRatingService {
  static StudentProfile createStudentProfile({
    required String id,
    required String name,
    required String email,
  }) {
    return StudentProfile(
      id: id,
      name: name,
      email: email,
      registrationDate: DateTime.now(),
      assessments: [],
      currentLevel: 'beginner',
    );
  }

  static StudentProfile addAssessmentToStudent(
    StudentProfile profile,
    StudentAssessment assessment,
  ) {
    final updatedAssessments = [...profile.assessments, assessment];
    return StudentProfile(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      registrationDate: profile.registrationDate,
      assessments: updatedAssessments,
      currentLevel: _updateStudentLevel(updatedAssessments),
    );
  }

  static String _updateStudentLevel(List<StudentAssessment> assessments) {
    if (assessments.isEmpty) return 'beginner';

    final averageScore =
        assessments.fold<double>(
          0,
          (sum, assessment) => sum + assessment.getPercentageScore(),
        ) /
        assessments.length;

    if (averageScore >= 80) return 'advanced';
    if (averageScore >= 60) return 'intermediate';
    return 'beginner';
  }

  static StudentReport generateStudentReport(StudentProfile profile) {
    final assessments = profile.assessments;

    final averageScore = profile.getAverageScore();
    final averageAccuracy =
        assessments.isEmpty
            ? 0
            : assessments.fold<double>(
                  0,
                  (sum, a) => sum + a.accuracyPercentage,
                ) /
                assessments.length;

    final severityDistribution = <String, int>{};
    for (final assessment in assessments) {
      severityDistribution[assessment.overallSeverity] =
          (severityDistribution[assessment.overallSeverity] ?? 0) + 1;
    }

    final categoryPerformance = <String, double>{};
    for (final assessment in assessments) {
      for (final entry in assessment.categoryScores.entries) {
        if (!categoryPerformance.containsKey(entry.key)) {
          categoryPerformance[entry.key] = 0;
        }
        categoryPerformance[entry.key] =
            (categoryPerformance[entry.key]! + entry.value) / 2;
      }
    }

    final totalTime = assessments.fold<int>(
      0,
      (sum, a) => sum + a.timeSpentSeconds,
    );
    final averageTime =
        assessments.isEmpty
            ? Duration.zero
            : Duration(seconds: (totalTime / assessments.length).toInt());

    final statistics = Statistics(
      averageScore: averageScore,
      averageAccuracy: averageAccuracy.toDouble(),
      progressPercentage: profile.getProgressPercentage(),
      totalAssessmentsTaken: assessments.length,
      severityDistribution: severityDistribution,
      categoryPerformance: categoryPerformance,
      averageTimePerAssessment: averageTime,
    );

    final recommendations = _generateRecommendations(profile, statistics);

    return StudentReport(
      profile: profile,
      recentAssessments:
          assessments.length > 5
              ? assessments.sublist(assessments.length - 5)
              : assessments,
      statistics: statistics,
      recommendations: recommendations,
    );
  }

  static List<Recommendation> _generateRecommendations(
    StudentProfile profile,
    Statistics statistics,
  ) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();

    if (statistics.averageScore < 60) {
      recommendations.add(
        Recommendation(
          id: 'rec_1',
          title: 'يحتاج إلى تحسين الأداء العام',
          description:
              'متوسط أدائك أقل من المتوقع. ننصحك بإعادة الاختبارات والعمل على تحسين فهمك.',
          category: 'improvement',
          priority: 5,
          isCompleted: false,
          createdDate: now,
        ),
      );
    } else if (statistics.averageScore >= 80) {
      recommendations.add(
        Recommendation(
          id: 'rec_2',
          title: 'استمر في التقدم الممتاز',
          description: 'أدؤك ممتاز! استمر في المحاولة وحاول الوصول إلى 100%.',
          category: 'assessment',
          priority: 1,
          isCompleted: false,
          createdDate: now,
        ),
      );
    }

    statistics.severityDistribution.forEach((severity, count) {
      if (severity == 'شديد' || severity == 'شديد جداً') {
        recommendations.add(
          Recommendation(
            id: 'rec_${recommendations.length}',
            title: 'تحذير: مستويات $severity مرتفعة',
            description:
                'لديك علامات $severity يُرجى استشارة متخصص نفسي لتقييم شامل.',
            category: 'intervention',
            priority: 5,
            isCompleted: false,
            createdDate: now,
          ),
        );
      }
    });

    if (statistics.progressPercentage < 50) {
      recommendations.add(
        Recommendation(
          id: 'rec_${recommendations.length}',
          title: 'زيادة عدد الاختبارات',
          description: 'حاول أخذ المزيد من الاختبارات لتقييم شامل لحالتك.',
          category: 'assessment',
          priority: 3,
          isCompleted: false,
          createdDate: now,
        ),
      );
    }

    return recommendations;
  }

  static double calculateStudentGrade(Statistics statistics) {
    return (statistics.averageScore * 0.6) + (statistics.averageAccuracy * 0.4);
  }

  static String classifyStudent(Statistics statistics) {
    final grade = calculateStudentGrade(statistics);

    if (grade >= 90) return 'A - ممتاز جداً';
    if (grade >= 80) return 'B - ممتاز';
    if (grade >= 70) return 'C - جيد';
    if (grade >= 60) return 'D - مقبول';
    return 'F - يحتاج تحسين';
  }

  static Map<String, dynamic> compareStudents(
    StudentProfile student1,
    StudentProfile student2,
  ) {
    final report1 = generateStudentReport(student1);
    final report2 = generateStudentReport(student2);

    return {
      'student1': {
        'name': student1.name,
        'averageScore': report1.statistics.averageScore,
        'assessmentCount': report1.statistics.totalAssessmentsTaken,
        'grade': classifyStudent(report1.statistics),
      },
      'student2': {
        'name': student2.name,
        'averageScore': report2.statistics.averageScore,
        'assessmentCount': report2.statistics.totalAssessmentsTaken,
        'grade': classifyStudent(report2.statistics),
      },
      'winner':
          report1.statistics.averageScore > report2.statistics.averageScore
              ? student1.name
              : student2.name,
    };
  }

  static List<StudentProfile> getTopStudents(
    List<StudentProfile> students, {
    int limit = 10,
  }) {
    students.sort((a, b) {
      final reportA = generateStudentReport(a);
      final reportB = generateStudentReport(b);
      return calculateStudentGrade(
        reportB.statistics,
      ).compareTo(calculateStudentGrade(reportA.statistics));
    });

    return students.take(limit).toList();
  }

  static Map<String, dynamic> analyzePerformancePattern(
    StudentProfile profile,
  ) {
    final assessments = profile.assessments;
    if (assessments.length < 2) {
      return {'trend': 'insufficient_data', 'message': 'بيانات غير كافية'};
    }

    assessments.sort((a, b) => a.completionDate.compareTo(b.completionDate));

    final firstHalf = assessments.take((assessments.length / 2).floor());
    final secondHalf = assessments.skip((assessments.length / 2).floor());

    final avgFirstHalf =
        firstHalf.isEmpty
            ? 0
            : firstHalf.fold<double>(
                  0,
                  (sum, a) => sum + a.getPercentageScore(),
                ) /
                firstHalf.length;

    final avgSecondHalf =
        secondHalf.isEmpty
            ? 0
            : secondHalf.fold<double>(
                  0,
                  (sum, a) => sum + a.getPercentageScore(),
                ) /
                secondHalf.length;

    final trend =
        avgSecondHalf > avgFirstHalf
            ? 'improving'
            : avgSecondHalf < avgFirstHalf
            ? 'declining'
            : 'stable';

    return {
      'trend': trend,
      'message':
          trend == 'improving'
              ? 'الأداء في تحسن'
              : trend == 'declining'
              ? 'الأداء في تراجع'
              : 'الأداء مستقر',
      'firstHalfAverage': avgFirstHalf,
      'secondHalfAverage': avgSecondHalf,
      'improvement': avgSecondHalf - avgFirstHalf,
    };
  }
}
