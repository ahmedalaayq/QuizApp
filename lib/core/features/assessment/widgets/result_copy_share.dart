import 'package:flutter/services.dart';
import 'package:quiz_app/core/models/assessment_model.dart';

class ResultCopyShare {
  static String buildShareText(AssessmentResult result) {
    final buffer = StringBuffer();
    buffer.writeln('نتيجة الاختبار');
    buffer.writeln('--------------------');
    buffer.writeln('الاختبار: ${result.assessmentTitle}');
    buffer.writeln('التاريخ: ${_formatDate(result.completionDate)}');
    buffer.writeln('الحالة الإجمالية: ${result.overallSeverity}');
    buffer.writeln('الإجمالي: ${result.totalScore} نقطة');
    buffer.writeln('');
    buffer.writeln('تفصيل النتائج:');
    result.categoryScores.forEach((key, value) {
      buffer.writeln('- $key: $value');
    });
    buffer.writeln('');
    buffer.writeln('تحليل مختصر:');
    buffer.writeln(result.interpretation);
    if (result.recommendations.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('توصيات:');
      for (int i = 0; i < result.recommendations.length; i++) {
        buffer.writeln('${i + 1}) ${result.recommendations[i]}');
      }
    }
    buffer.writeln('');
    buffer.writeln('تنويه: النتائج للتوعية وليست تشخيصاً طبياً.');
    return buffer.toString();
  }

  static Future<void> copyToClipboard(AssessmentResult result) async {
    await Clipboard.setData(ClipboardData(text: buildShareText(result)));
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }
}

