import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  static Future<void> exportSingleReport(AssessmentHistory assessment) async {
    try {
      // Show loading with proper dark mode colors
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'جاري التصدير',
        'يتم تحضير التقرير...',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.blue,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Validate assessment data
      if (assessment.assessmentTitle.isEmpty) {
        throw Exception('بيانات التقييم غير مكتملة');
      }

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

                pw.Text(
                  'التفسير:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  assessment.interpretation.isNotEmpty
                      ? assessment.interpretation
                      : 'لا توجد تفسيرات متاحة',
                  style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.right,
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'التوصيات:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                if (assessment.recommendations.isNotEmpty)
                  ...assessment.recommendations.map(
                    (rec) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '• ',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
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
                  )
                else
                  pw.Text(
                    'لا توجد توصيات متاحة',
                    style: const pw.TextStyle(fontSize: 14),
                    textAlign: pw.TextAlign.right,
                  ),

                pw.Spacer(),

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

      await _savePdf(
        pdf,
        'تقرير_${assessment.assessmentType}_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'خطأ في التصدير',
        'فشل في تصدير التقرير: ${e.toString()}',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  static Future<void> exportFullReport(
    List<AssessmentHistory> assessments,
  ) async {
    try {
      final pdf = pw.Document();
      final arabicFont = await _loadArabicFont();

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
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'خطأ',
        'فشل في تصدير التقرير الشامل: $e',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'خطأ',
        'فشل في طباعة التقرير: $e',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<pw.Font> _loadArabicFont() async {
    try {
      // Try to load Cairo Regular font first
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final font = pw.Font.ttf(fontData);
      return font;
    } catch (e) {
      try {
        // Fallback to Cairo Medium font
        final fallbackFontData = await rootBundle.load(
          'assets/fonts/Cairo-Medium.ttf',
        );
        final font = pw.Font.ttf(fallbackFontData);
        return font;
      } catch (e2) {
        try {
          // Try Cairo Bold as another fallback
          final boldFontData = await rootBundle.load(
            'assets/fonts/Cairo-Bold.ttf',
          );
          final font = pw.Font.ttf(boldFontData);
          return font;
        } catch (e3) {
          // Use default PDF font as last resort
          return pw.Font.helvetica();
        }
      }
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
      // Validate inputs
      if (filename.isEmpty) {
        throw Exception('اسم الملف فارغ');
      }

      // Get the temporary directory with better error handling
      Directory? output;
      try {
        output = await getTemporaryDirectory();
      } catch (e) {
        throw Exception('فشل في الوصول إلى مجلد التخزين المؤقت: $e');
      }

      // Create a safe filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFilename = filename
          .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF-]'), '_')
          .replaceAll(RegExp(r'\s+'), '_');
      final fullFilename = '${safeFilename}_$timestamp.pdf';
      final file = File('${output.path}/$fullFilename');

      // Generate PDF bytes with error handling
      Uint8List pdfBytes;
      try {
        pdfBytes = await pdf.save();
      } catch (e) {
        throw Exception('فشل في إنشاء محتوى PDF: $e');
      }

      // Validate PDF bytes
      if (pdfBytes.isEmpty) {
        throw Exception('محتوى PDF فارغ');
      }

      // Write to file with retry mechanism
      int retryCount = 0;
      bool fileWritten = false;

      while (retryCount < 3 && !fileWritten) {
        try {
          await file.writeAsBytes(pdfBytes);
          fileWritten = true;
        } catch (e) {
          retryCount++;
          if (retryCount < 3) {
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
          } else {
            throw Exception('فشل في كتابة الملف بعد $retryCount محاولات: $e');
          }
        }
      }

      // Verify file was created and has content
      if (!await file.exists()) {
        throw Exception('الملف لم يتم إنشاؤه');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        await file.delete(); // Clean up empty file
        throw Exception('الملف تم إنشاؤه لكنه فارغ');
      }

      // Validate file size is reasonable (at least 1KB, max 50MB)
      if (fileSize < 1024) {
        await file.delete();
        throw Exception('حجم الملف صغير جداً ($fileSize bytes)');
      }

      if (fileSize > 50 * 1024 * 1024) {
        await file.delete();
        throw Exception(
          'حجم الملف كبير جداً (${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB)',
        );
      }

      // Share the file with error handling
      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'تقرير التقييم النفسي',
          subject: 'تقرير التقييم النفسي',
        );
      } catch (shareError) {
        // File was created successfully, but sharing failed
        // This is not a critical error, just inform the user
        final isDarkMode = Get.isDarkMode;
        Get.snackbar(
          'تنبيه',
          'تم إنشاء الملف بنجاح لكن فشل في المشاركة. الملف محفوظ في: ${file.path}',
          backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.orange,
          colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return; // Don't throw error, file was created successfully
      }

      // Success message
      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'نجح التصدير',
        'تم تصدير التقرير بنجاح (${(fileSize / 1024).toStringAsFixed(1)} KB)',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.green,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // More detailed error handling with specific error types
      String errorMessage = 'فشل في حفظ الملف';
      String errorDetails = e.toString();

      if (errorDetails.contains('Permission denied') ||
          errorDetails.contains('Access denied')) {
        errorMessage = 'لا توجد صلاحية للكتابة في المجلد';
      } else if (errorDetails.contains('No space left') ||
          errorDetails.contains('Storage full')) {
        errorMessage = 'لا توجد مساحة كافية على الجهاز';
      } else if (errorDetails.contains('File not found') ||
          errorDetails.contains('Directory not found')) {
        errorMessage = 'لم يتم العثور على المجلد المطلوب';
      } else if (errorDetails.contains('Network')) {
        errorMessage = 'مشكلة في الشبكة أثناء الحفظ';
      } else if (errorDetails.contains('timeout') ||
          errorDetails.contains('Timeout')) {
        errorMessage = 'انتهت مهلة العملية';
      } else if (errorDetails.contains('font') ||
          errorDetails.contains('Font')) {
        errorMessage = 'مشكلة في تحميل الخط العربي';
      } else if (errorDetails.contains('PDF') || errorDetails.contains('pdf')) {
        errorMessage = 'مشكلة في إنشاء ملف PDF';
      }

      final isDarkMode = Get.isDarkMode;
      Get.snackbar(
        'خطأ في التصدير',
        '$errorMessage\nالتفاصيل: $errorDetails',
        backgroundColor: isDarkMode ? const Color(0xFF21262D) : Colors.red,
        colorText: isDarkMode ? const Color(0xFFF0F6FC) : Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );

      throw Exception('$errorMessage: $e');
    }
  }
}
