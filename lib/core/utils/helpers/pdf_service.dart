import 'dart:typed_data';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QuizPdfService {
  static Future<Uint8List> buildTemplatePdf(PublishedQuizTemplate template) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            template.title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            template.description.isEmpty
                ? 'Quiz Template Export'
                : template.description,
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 12),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Type: ${template.type}'),
                pw.Text('Level: ${template.level}'),
                pw.Text('Questions: ${template.items.length}'),
                pw.Text('Estimated time: ${template.estimatedMinutes} min'),
                if (template.tags.isNotEmpty)
                  pw.Text('Tags: ${template.tags.join(', ')}'),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          ...List.generate(template.items.length, (index) {
            final item = template.items[index];

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Question ${index + 1} • ${_typeLabel(item.type)} • ${item.points} pt${item.points == 1 ? '' : 's'}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    item.question.isEmpty ? '(No question text)' : item.question,
                    style: const pw.TextStyle(fontSize: 12),
                  ),

                  if (item.options.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    ...List.generate(item.options.length, (optIndex) {
                      final option = item.options[optIndex];
                      final isCorrect =
                      item.correctOptionIndexes.contains(optIndex);

                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('${String.fromCharCode(65 + optIndex)}. '),
                            pw.Expanded(
                              child: pw.Text(
                                option.isEmpty ? '(Blank option)' : option,
                                style: pw.TextStyle(
                                  fontWeight: isCorrect
                                      ? pw.FontWeight.bold
                                      : pw.FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  if ((item.answerKey ?? '').trim().isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Answer: ${item.answerKey!.trim()}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> exportTemplateToPdf(PublishedQuizTemplate template) async {
    await Printing.layoutPdf(
      name: '${template.title}.pdf',
      onLayout: (PdfPageFormat format) async => buildTemplatePdf(template),
    );
  }

  static Future<void> shareTemplatePdf(PublishedQuizTemplate template) async {
    final bytes = await buildTemplatePdf(template);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${template.title}.pdf',
    );
  }

  static String _typeLabel(QuizItemType type) {
    switch (type) {
      case QuizItemType.shortAnswer:
        return 'Short Answer';
      case QuizItemType.multipleChoice:
        return 'Multiple Choice';
      case QuizItemType.trueFalse:
        return 'True / False';
      case QuizItemType.essay:
        return 'Essay';
    }
  }
}