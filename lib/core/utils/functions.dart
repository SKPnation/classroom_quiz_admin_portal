import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

DateTime parseDate(dynamic value) {
  if (value == null) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  if (value is DateTime) {
    return value;
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

QuizItemType typeFromLabel(String label) {
  switch (label) {
    case 'True/False':
      return QuizItemType.trueFalse;
    case 'Short Answer':
      return QuizItemType.shortAnswer;
    case 'Essay':
      return QuizItemType.essay;
    default:
      return QuizItemType.multipleChoice;
  }
}

String typeLabel(QuizItemType type) {
  switch (type) {
    case QuizItemType.multipleChoice:
      return 'Multiple Choice';
    case QuizItemType.shortAnswer:
      return 'Short Answer';
    case QuizItemType.trueFalse:
      return 'True / False';
    case QuizItemType.essay:
      return 'Essay';
    }
}

bool isProCount(int count) => count == 15 || count == 20;

Future<String> extractTextFromFile({
  required List<int> fileBytes,
  required String fileName,
}) async {
  // Replace with your actual Firebase Function URL after deploying
  const extractUrl =
      'https://us-central1-schoolquizapp-8b07d.cloudfunctions.net/extractNotesText';

  final uri = Uri.parse(extractUrl);

  final extension = fileName.split('.').last.toLowerCase();
  final mimeType = extension == 'pdf'
      ? 'application/pdf'
      : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  final request = http.MultipartRequest('POST', uri)
    ..files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode != 200) {
    throw Exception('Extraction failed: ${response.body}');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;

  if (decoded['status'] != 'success') {
    throw Exception(decoded['message'] ?? 'Extraction failed.');
  }

  return decoded['text'] as String;
}

String? get myUID => FirebaseAuth.instance.currentUser?.uid;