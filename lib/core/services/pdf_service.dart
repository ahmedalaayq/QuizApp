import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:quiz_app/core/database/models/assessment_history_model.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  // تصدير تقرير واحد
  static Future<void> exportSingleReport(AssessmentHistory assessment) async {
    try {
      final pdf = pw.Document();

      // تحميل الخط العربي
      final arabicFont = await _loadArabicFont();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // العنوان
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'تقرير التقييم النفسي',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        assessment.assessmentTitle,
                        style: const pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // معلومات التقرير
                _buildInfoSection(
                  'التاريخ',
                  _formatDate(assessment.completionDate),
                ),
                _buildInfoSection(
                  'المدة',
                  '${assessment.durationInSeconds ~/ 60} دقيقة',
                ),
                _buildInfoSection(
                  'النتيجة الإجمالية',
                  '${assessment.totalScore}',
                ),
                _buildInfoSection('مستوى الشدة', assessment.overallSeverity),

                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                // التفسير
                pw.Text(
                  'التفسير:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  assessment.interpretation,
                  style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.right,
                ),

                pw.SizedBox(height: 20),

                // التوصيات
                pw.Text(
                  'التوصيات:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ...assessment.recommendations.map(
                  (rec) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: const pw.TextStyle(fontSize: 14)),
                        pw.Expanded(
                          child: pw.Text(
                            rec,
                            style: const pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // تنويه
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange50,
                    border: pw.Border.all(color: PdfColors.orange),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'تنويه: هذا التقرير لأغراض تقييمية فقط ولا يعتبر تشخيصاً طبياً. يُنصح باستشارة متخصص نفسي معتمد.',
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // حفظ ومشاركة
      await _savePdf(
        pdf,
        'تقرير_${assessment.assessmentType}_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تصدير التقرير: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تصدير تقرير شامل
  static Future<void> exportFullReport(
    List<AssessmentHistory> assessments,
  ) async {
    try {
      final pdf = pw.Document();
      final arabicFont = await _loadArabicFont();

      // صفحة الغلاف
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'التقرير الشامل',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'منصة التقييم النفسي',
                    style: const pw.TextStyle(fontSize: 24),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'التاريخ: ${_formatDate(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'عدد الاختبارات: ${assessments.length}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // صفحة الإحصائيات
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) {
            final avgScore =
                assessments.fold<int>(0, (sum, a) => sum + a.totalScore) /
                assessments.length;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'الإحصائيات العامة',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),
                _buildStatRow('إجمالي الاختبارات', '${assessments.length}'),
                _buildStatRow('متوسط النتائج', avgScore.toStringAsFixed(1)),
                _buildStatRow(
                  'أول اختبار',
                  _formatDate(assessments.last.completionDate),
                ),
                _buildStatRow(
                  'آخر اختبار',
                  _formatDate(assessments.first.completionDate),
                ),
              ],
            );
          },
        ),
      );

      // صفحات الاختبارات
      for (var assessment in assessments) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: arabicFont),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    assessment.assessmentTitle,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  _buildInfoSection(
                    'التاريخ',
                    _formatDate(assessment.completionDate),
                  ),
                  _buildInfoSection('النتيجة', '${assessment.totalScore}'),
                  _buildInfoSection('الشدة', assessment.overallSeverity),
                  pw.SizedBox(height: 15),
                  pw.Text(
                    'التفسير:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    assessment.interpretation,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              );
            },
          ),
        );
      }

      await _savePdf(
        pdf,
        'تقرير_شامل_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تصدير التقرير الشامل: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // طباعة التقرير
  static Future<void> printReport(AssessmentHistory assessment) async {
    try {
      final pdf = pw.Document();
      final arabicFont = await _loadArabicFont();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  assessment.assessmentTitle,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildInfoSection(
                  'التاريخ',
                  _formatDate(assessment.completionDate),
                ),
                _buildInfoSection('النتيجة', '${assessment.totalScore}'),
                _buildInfoSection('الشدة', assessment.overallSeverity),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في طباعة التقرير: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper methods
  static Future<pw.Font> _loadArabicFont() async {
    // يمكن استخدام خط Cairo من assets
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      // fallback to default
      return pw.Font.ttf(
        await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
      );
    }
  }

  static pw.Widget _buildInfoSection(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  static pw.Widget _buildStatRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  static Future<void> _savePdf(pw.Document pdf, String filename) async {
    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$filename.pdf');
      await file.writeAsBytes(await pdf.save());

      // مشاركة الملف
      await Share.shareXFiles([XFile(file.path)], text: 'تقرير التقييم النفسي');

      Get.snackbar(
        'نجح',
        'تم تصدير التقرير بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      throw Exception('فشل في حفظ الملف: $e');
    }
  }
}
