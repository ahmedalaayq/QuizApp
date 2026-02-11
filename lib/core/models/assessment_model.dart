/// نموذج الاختبار النفسي - يمثل اختبار كامل
class Assessment {
  final String id;
  final String title;
  final String description;
  final String assessmentType;
  final List<Question> questions;
  final String language;

  Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.assessmentType,
    required this.questions,
    this.language = 'ar',
  });

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'assessmentType': assessmentType,
    'questions': questions.map((q) => q.toJson()).toList(),
    'language': language,
  };
}

/// نموذج السؤال
class Question {
  final String id;
  final String text;
  final String category;
  final List<Answer> answers;
  final int order;

  Question({
    required this.id,
    required this.text,
    required this.category,
    required this.answers,
    required this.order,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'text': text,
    'category': category,
    'answers': answers.map((a) => a.toJson()).toList(),
    'order': order,
  };
}

/// نموذج الإجابة
class Answer {
  final String id;
  final String text;
  final int score;
  final String severity;

  Answer({
    required this.id,
    required this.text,
    required this.score,
    required this.severity,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'text': text,
    'score': score,
    'severity': severity,
  };
}

/// نموذج إجابة المستخدم
class UserResponse {
  final String questionId;
  final String answerId;
  final String answerText;
  final int score;
  final String category;

  UserResponse({
    required this.questionId,
    required this.answerId,
    required this.answerText,
    required this.score,
    required this.category,
  });

  Map<String, Object> toJson() => {
    'questionId': questionId,
    'answerId': answerId,
    'answerText': answerText,
    'score': score,
    'category': category,
  };
}

/// نموذج نتائج الاختبار
class AssessmentResult {
  final String id;
  final String assessmentId;
  final String assessmentTitle;
  final List<UserResponse> responses;
  final int totalScore;
  final Map<String, int> categoryScores;
  final String overallSeverity;
  final DateTime completionDate;
  final String interpretation;
  final List<String> recommendations;

  AssessmentResult({
    required this.id,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.responses,
    required this.totalScore,
    required this.categoryScores,
    required this.overallSeverity,
    required this.completionDate,
    required this.interpretation,
    required this.recommendations,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'assessmentId': assessmentId,
    'assessmentTitle': assessmentTitle,
    'responses': responses.map((r) => r.toJson()).toList(),
    'totalScore': totalScore,
    'categoryScores': categoryScores,
    'overallSeverity': overallSeverity,
    'completionDate': completionDate.toIso8601String(),
    'interpretation': interpretation,
    'recommendations': recommendations,
  };
}
