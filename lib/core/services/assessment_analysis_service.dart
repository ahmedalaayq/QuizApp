import 'package:quiz_app/core/models/assessment_model.dart';

/// خدمة تحليل النتائج وتقييم الحالة
class AssessmentAnalysisService {
  static AssessmentResult analyzeDASS21(
    Assessment assessment,
    List<UserResponse> responses,
  ) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final depressionScores =
        responses
            .where((r) => r.category == 'depression')
            .map((r) => r.score)
            .toList();

    final anxietyScores =
        responses
            .where((r) => r.category == 'anxiety')
            .map((r) => r.score)
            .toList();

    final stressScores =
        responses
            .where((r) => r.category == 'stress')
            .map((r) => r.score)
            .toList();

    final depressionScore =
        depressionScores.isEmpty ? 0 : depressionScores.reduce((a, b) => a + b);

    final anxietyScore =
        anxietyScores.isEmpty ? 0 : anxietyScores.reduce((a, b) => a + b);

    final stressScore =
        stressScores.isEmpty ? 0 : stressScores.reduce((a, b) => a + b);

    final totalScore = depressionScore + anxietyScore + stressScore;

    final overallSeverity = _getDASSOverallSeverity(
      depressionScore,
      anxietyScore,
      stressScore,
    );

    final interpretation = _getDASS21Interpretation(
      depressionScore,
      anxietyScore,
      stressScore,
    );

    final recommendations = _getDASS21Recommendations(
      depressionScore,
      anxietyScore,
      stressScore,
    );

    return AssessmentResult(
      id: id,
      assessmentId: assessment.id,
      assessmentTitle: assessment.title,
      responses: responses,
      totalScore: totalScore,
      categoryScores: {
        'اكتئاب': depressionScore,
        'قلق': anxietyScore,
        'إجهاد': stressScore,
      },
      overallSeverity: overallSeverity,
      completionDate: DateTime.now(),
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  static AssessmentResult analyzeAutism(
    Assessment assessment,
    List<UserResponse> responses,
  ) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final socialScores =
        responses
            .where((r) => r.category == 'social')
            .map((r) => r.score)
            .toList();

    final restrictedScores =
        responses
            .where((r) => r.category == 'restricted')
            .map((r) => r.score)
            .toList();

    final sensoryScores =
        responses
            .where((r) => r.category == 'sensory')
            .map((r) => r.score)
            .toList();

    final socialScore =
        socialScores.isEmpty ? 0 : socialScores.reduce((a, b) => a + b);

    final restrictedScore =
        restrictedScores.isEmpty ? 0 : restrictedScores.reduce((a, b) => a + b);

    final sensoryScore =
        sensoryScores.isEmpty ? 0 : sensoryScores.reduce((a, b) => a + b);

    final totalScore = socialScore + restrictedScore + sensoryScore;

    final overallSeverity = _getAutismSeverity(totalScore);

    final interpretation = _getAutismInterpretation(
      totalScore,
      socialScore,
      restrictedScore,
      sensoryScore,
    );

    final recommendations = _getAutismRecommendations(
      socialScore,
      restrictedScore,
      sensoryScore,
    );

    return AssessmentResult(
      id: id,
      assessmentId: assessment.id,
      assessmentTitle: assessment.title,
      responses: responses,
      totalScore: totalScore,
      categoryScores: {
        'التواصل الاجتماعي': socialScore,
        'السلوكيات المقيدة': restrictedScore,
        'الحساسية الحسية': sensoryScore,
      },
      overallSeverity: overallSeverity,
      completionDate: DateTime.now(),
      interpretation: interpretation,
      recommendations: recommendations,
    );
  }

  static String _getDASSOverallSeverity(
    int depression,
    int anxiety,
    int stress,
  ) {
    final avg = (depression + anxiety + stress) / 3;

    if (avg < 5) return 'طبيعي';
    if (avg < 10) return 'خفيف';
    if (avg < 15) return 'معتدل';
    if (avg < 20) return 'شديد';
    return 'شديد جداً';
  }

  static String _getDASS21Interpretation(
    int depression,
    int anxiety,
    int stress,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('تحليل النتائج:\n');
    buffer.writeln('الاكتئاب:');
    if (depression < 5) {
      buffer.writeln('درجتك طبيعية. لا توجد علامات اكتئاب واضحة.');
    } else if (depression < 10) {
      buffer.writeln('درجتك خفيفة. قد تشعر ببعض أعراض الاكتئاب البسيطة.');
    } else if (depression < 15) {
      buffer.writeln(
        'درجتك معتدلة. تشير إلى أعراض اكتئاب واضحة قد تؤثر على حياتك اليومية.',
      );
    } else if (depression < 20) {
      buffer.writeln(
        'درجتك شديدة. تشير إلى أعراض اكتئاب كبيرة تحتاج متابعة متخصصة.',
      );
    } else {
      buffer.writeln('درجتك شديدة جداً. يُنصح بطلب مساعدة نفسية فورية.');
    }

    buffer.writeln('\n🟠 **القلق:**');
    if (anxiety < 5) {
      buffer.writeln('درجتك طبيعية. لا توجد علامات قلق ملحوظة.');
    } else if (anxiety < 10) {
      buffer.writeln('درجتك خفيفة. قد تشعر ببعض القلق العرضي.');
    } else if (anxiety < 15) {
      buffer.writeln('درجتك معتدلة. تشير إلى مستويات قلق قابلة للملاحظة.');
    } else if (anxiety < 20) {
      buffer.writeln('درجتك شديدة. تشير إلى قلق كبير يحتاج تدخل متخصص.');
    } else {
      buffer.writeln('درجتك شديدة جداً. ننصحك بالتواصل مع متخصص فوراً.');
    }

    buffer.writeln('\n🟡 **الإجهاد:**');
    if (stress < 5) {
      buffer.writeln('درجتك طبيعية. تتعامل مع الضغوط بشكل جيد.');
    } else if (stress < 10) {
      buffer.writeln('درجتك خفيفة. قد تشعر ببعض الضغط لكنه قابل للتحكم.');
    } else if (stress < 15) {
      buffer.writeln('درجتك معتدلة. تشير إلى مستوى إجهاد ملحوظ في حياتك.');
    } else if (stress < 20) {
      buffer.writeln('درجتك شديدة. تشير إلى إجهاد كبير قد يؤثر على صحتك.');
    } else {
      buffer.writeln('درجتك شديدة جداً. يجب البحث عن مساعدة متخصصة.');
    }

    return buffer.toString();
  }

  static List<String> _getDASS21Recommendations(
    int depression,
    int anxiety,
    int stress,
  ) {
    final recommendations = <String>[];

    recommendations.add('استشر طبيباً نفسياً أو معالجاً متخصصاً');
    recommendations.add('جرب تقنيات الاسترخاء والتأمل');
    recommendations.add('مارس الرياضة بانتظام 30 دقيقة يومياً');
    recommendations.add('حافظ على روتين نوم صحي');
    recommendations.add('قضِ وقتاً مع الأشخاص المقربين');

    if (depression >= 10) {
      recommendations.add('ابحث عن الأنشطة التي تجلب لك السعادة');
      recommendations.add('حدد أهدافاً صغيرة وحقق إنجازات يومية');
    }

    if (anxiety >= 10) {
      recommendations.add('جرب الموسيقى الهادئة والأصوات المريحة');
      recommendations.add('تجنب الكافيين والمنبهات');
    }

    if (stress >= 10) {
      recommendations.add('نظم وقتك بشكل أفضل');
      recommendations.add('تعلم قول "لا" للالتزامات الإضافية');
    }

    return recommendations;
  }

  static String _getAutismSeverity(int totalScore) {
    if (totalScore < 10) return 'منخفض';
    if (totalScore < 20) return 'معتدل';
    if (totalScore < 25) return 'عالي';
    return 'عالي جداً';
  }

  static String _getAutismInterpretation(
    int totalScore,
    int socialScore,
    int restrictedScore,
    int sensoryScore,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('تقييم الخصائص:\n');

    buffer.writeln('التواصل الاجتماعي ($socialScore نقطة):');
    if (socialScore < 5) {
      buffer.writeln('- مهارات اجتماعية طبيعية نسبياً');
    } else if (socialScore < 10) {
      buffer.writeln('- بعض الصعوبات في التفاعل الاجتماعي');
    } else {
      buffer.writeln('- صعوبات واضحة في التواصل والتفاعل الاجتماعي');
    }

    buffer.writeln('\nالسلوكيات المقيدة والمتكررة ($restrictedScore نقطة):');
    if (restrictedScore < 5) {
      buffer.writeln('- سلوكيات مرنة وغير مقيدة');
    } else if (restrictedScore < 10) {
      buffer.writeln('- بعض الأنماط السلوكية المقيدة أو المتكررة');
    } else {
      buffer.writeln('- أنماط سلوكية مقيدة واضحة وحساسية للتغيير');
    }

    buffer.writeln('\nالحساسية الحسية ($sensoryScore نقطة):');
    if (sensoryScore < 5) {
      buffer.writeln('- حساسية حسية طبيعية');
    } else if (sensoryScore < 10) {
      buffer.writeln('- بعض الحساسيات الحسية الملحوظة');
    } else {
      buffer.writeln('- حساسيات حسية عالية جداً تؤثر على الراحة');
    }

    buffer.writeln('\n\n⚠️ **الملاحظة المهمة:**');
    buffer.writeln(
      'هذا المقياس لا يغني عن التقييم المتخصص من قبل طبيب نفسي '
      'أو متخصص في النمو العصبي. يرجى التواصل مع متخصص لتقييم شامل.',
    );

    return buffer.toString();
  }

  static List<String> _getAutismRecommendations(
    int socialScore,
    int restrictedScore,
    int sensoryScore,
  ) {
    final recommendations = <String>[];

    recommendations.add('تقييم شامل من متخصص في الحالات النمائية');
    recommendations.add('العلاج السلوكي أو العلاج الاجتماعي إن وجد');

    if (socialScore >= 10) {
      recommendations.add('تدريب مهارات التواصل الاجتماعي');
      recommendations.add('العمل على مهارات فهم تعابير الوجه والإيماءات');
    }

    if (restrictedScore >= 10) {
      recommendations.add('تدريب تدريجي على المرونة والتعامل مع التغيير');
      recommendations.add('إنشاء روتينات منظمة مع فترات انتقالية');
    }

    if (sensoryScore >= 10) {
      recommendations.add(
        'التحكم ببيئة العمل (تقليل الأصوات والأضواء الزاهية)',
      );
      recommendations.add('البحث عن محفزات حسية آمنة ومريحة');
    }

    return recommendations;
  }
}
