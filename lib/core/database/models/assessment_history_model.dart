import 'package:hive/hive.dart';

part 'assessment_history_model.g.dart';

@HiveType(typeId: 0)
class AssessmentHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String assessmentType;

  @HiveField(2)
  final String assessmentTitle;

  @HiveField(3)
  final DateTime completionDate;

  @HiveField(4)
  final int totalScore;

  @HiveField(5)
  final Map<String, dynamic> categoryScores;

  @HiveField(6)
  final String overallSeverity;

  @HiveField(7)
  final String interpretation;

  @HiveField(8)
  final List<String> recommendations;

  @HiveField(9)
  final int durationInSeconds;

  AssessmentHistory({
    required this.id,
    required this.assessmentType,
    required this.assessmentTitle,
    required this.completionDate,
    required this.totalScore,
    required this.categoryScores,
    required this.overallSeverity,
    required this.interpretation,
    required this.recommendations,
    this.durationInSeconds = 0,
  });

  factory AssessmentHistory.fromJson(Map<String, dynamic> json) {
    return AssessmentHistory(
      id: json['id'] as String,
      assessmentType: json['assessmentType'] as String,
      assessmentTitle: json['assessmentTitle'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
      totalScore: json['totalScore'] as int,
      categoryScores: Map<String, dynamic>.from(json['categoryScores'] as Map),
      overallSeverity: json['overallSeverity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
      durationInSeconds: json['durationInSeconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessmentType': assessmentType,
      'assessmentTitle': assessmentTitle,
      'completionDate': completionDate.toIso8601String(),
      'totalScore': totalScore,
      'categoryScores': categoryScores,
      'overallSeverity': overallSeverity,
      'interpretation': interpretation,
      'recommendations': recommendations,
      'durationInSeconds': durationInSeconds,
    };
  }

  double getPercentage() {
    if (assessmentType.toUpperCase() == 'DASS') {
      return (totalScore / 63) * 100;
    } else if (assessmentType.toUpperCase() == 'AUTISM') {
      return (totalScore / 30) * 100;
    }
    return 0;
  }

  String getSeverityColor() {
    switch (overallSeverity.toLowerCase()) {
      case 'طبيعي':
      case 'normal':
        return '#4CAF50';
      case 'خفيف':
      case 'mild':
        return '#8BC34A';
      case 'معتدل':
      case 'moderate':
        return '#FFC107';
      case 'شديد':
      case 'severe':
        return '#FF9800';
      case 'شديد جداً':
      case 'extremely severe':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }
}
