/// نموذج بيانات الطالب وتقييمه
class StudentProfile {
  final String id;
  final String name;
  final String email;
  final DateTime registrationDate;
  final List<StudentAssessment> assessments;
  final String currentLevel;

  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.registrationDate,
    required this.assessments,
    this.currentLevel = 'beginner',
  });

  double getAverageScore() {
    if (assessments.isEmpty) return 0;
    final total = assessments.fold<int>(
      0,
      (sum, assessment) => sum + assessment.totalScore,
    );
    return total / assessments.length;
  }

  int getCompletedAssessmentsCount() => assessments.length;

  StudentAssessment? getLastAssessment() {
    if (assessments.isEmpty) return null;
    assessments.sort((a, b) => b.completionDate.compareTo(a.completionDate));
    return assessments.first;
  }

  double getProgressPercentage() {
    final assessmentCount = assessments.length;

    return ((assessmentCount / 5) * 100).clamp(0, 100).toDouble();
  }

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'registrationDate': registrationDate.toIso8601String(),
    'assessments': assessments.map((a) => a.toJson()).toList(),
    'currentLevel': currentLevel,
  };
}

/// نموذج تقييم الطالب
class StudentAssessment {
  final String id;
  final String assessmentId;
  final String assessmentTitle;
  final int totalScore;
  final int maxScore;
  final Map<String, int> categoryScores;
  final String overallSeverity;
  final DateTime completionDate;
  final int timeSpentSeconds;
  final double accuracyPercentage;
  final String? notes;

  StudentAssessment({
    required this.id,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.totalScore,
    required this.maxScore,
    required this.categoryScores,
    required this.overallSeverity,
    required this.completionDate,
    required this.timeSpentSeconds,
    required this.accuracyPercentage,
    this.notes,
  });

  double getPercentageScore() => (totalScore / maxScore) * 100;

  String getPerformanceRating() {
    final percentage = getPercentageScore();
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 70) return 'جيد';
    if (percentage >= 60) return 'مقبول';
    return 'يحتاج إلى تحسين';
  }

  String getPerformanceColor() {
    final percentage = getPercentageScore();
    if (percentage >= 90) return '#4CAF50';
    if (percentage >= 80) return '#8BC34A';
    if (percentage >= 70) return '#FFC107';
    if (percentage >= 60) return '#FF9800';
    return '#F44336';
  }

  String getFormattedTime() {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '$minutes د $seconds ث';
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'assessmentId': assessmentId,
    'assessmentTitle': assessmentTitle,
    'totalScore': totalScore,
    'maxScore': maxScore,
    'categoryScores': categoryScores,
    'overallSeverity': overallSeverity,
    'completionDate': completionDate.toIso8601String(),
    'timeSpentSeconds': timeSpentSeconds,
    'accuracyPercentage': accuracyPercentage,
    'notes': notes,
  };
}

/// نموذج تقرير الطالب الشامل
class StudentReport {
  final StudentProfile profile;
  final List<StudentAssessment> recentAssessments;
  final Statistics statistics;
  final List<Recommendation> recommendations;

  StudentReport({
    required this.profile,
    required this.recentAssessments,
    required this.statistics,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'recentAssessments': recentAssessments.map((a) => a.toJson()).toList(),
    'statistics': statistics.toJson(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
  };
}

/// إحصائيات الطالب
class Statistics {
  final double averageScore;
  final double averageAccuracy;
  final double progressPercentage;
  final int totalAssessmentsTaken;
  final Map<String, int> severityDistribution;
  final Map<String, double> categoryPerformance;
  final Duration averageTimePerAssessment;

  Statistics({
    required this.averageScore,
    required this.averageAccuracy,
    required this.progressPercentage,
    required this.totalAssessmentsTaken,
    required this.severityDistribution,
    required this.categoryPerformance,
    required this.averageTimePerAssessment,
  });

  Map<String, Object> toJson() => {
    'averageScore': averageScore,
    'averageAccuracy': averageAccuracy,
    'progressPercentage': progressPercentage,
    'totalAssessmentsTaken': totalAssessmentsTaken,
    'severityDistribution': severityDistribution,
    'categoryPerformance': categoryPerformance,
    'averageTimePerAssessment': averageTimePerAssessment.inSeconds,
  };
}

/// التوصيات المخصصة للطالب
class Recommendation {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority;
  final bool isCompleted;
  final DateTime createdDate;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.isCompleted,
    required this.createdDate,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'priority': priority,
    'isCompleted': isCompleted,
    'createdDate': createdDate.toIso8601String(),
  };
}
