import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/pdf_service.dart';
import 'package:classroom_quiz_admin_portal/core/utils/services/functions_service.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/repos/quiz_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PublishedQuizzesController extends GetxController {
  static PublishedQuizzesController get instance => Get.find<PublishedQuizzesController>();
  QuizRepoImpl quizRepo = QuizRepoImpl();
  final String scriptUrl = AppStrings.webAppUrl;
  RxBool isLoading = false.obs;

  final RxList<PublishedQuizTemplate> publishedTemplates =
      <PublishedQuizTemplate>[].obs;

  List<QuizItemModel> cloneQuizItems(List<QuizItemModel> source) {
    return source.map((q) {
      return QuizItemModel(
        id: q.id,
        type: q.type,
        question: q.question,
        answerKey: q.answerKey,
        options: List<String>.from(q.options),
        correctOptionIndexes: List<int>.from(q.correctOptionIndexes),
        points: q.points,
        createdAt: q.createdAt,
      );
    }).toList();
  }

  Future<void> publishTemplate(PublishedQuizTemplate template) async {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    final existingIndex = publishedTemplates.indexWhere(
          (t) => t.id == template.id,
    );

    if (existingIndex != -1) {
      publishedTemplates[existingIndex] = template;
    } else {
      publishedTemplates.insert(0, template);
    }

    publishedTemplates.refresh();

    final userModel = UserModel.fromJson(userInfoCache);

    await quizRepo.addToTemplates(
      template: template,
      orgId: userModel.orgId,
    );
  }

  void deleteTemplate(PublishedQuizTemplate template) {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    var title = template.title;
    UserModel userModel = UserModel.fromJson(userInfoCache);
    publishedTemplates.removeWhere((t) => t.id == template.id);
    quizRepo.deleteTemplate(templateId: template.id, orgId: userModel.orgId);

    CustomSnackBar.successSnackBar(body: "$title deleted successfully");
  }

  // void exportTemplate(PublishedQuizTemplate template) async {
  //   try {
  //     await QuizPdfService.shareTemplatePdf(template);
  //   } catch (e) {
  //     CustomSnackBar.errorSnackBar('Failed to export PDF: $e');
  //   }
  // }

  // Future<void> handleGoogleFormsExport({
  //   required PublishedQuizTemplate template,
  // }) async {
  //   try {
  //     final payload = {
  //       "title": template.title,
  //       "description": template.description,
  //       "questions": template.items
  //           .map(
  //             (q) => {
  //               "type": q.type.name,
  //               "question": q.question,
  //               "options": q.options,
  //               "correctOptionIndexes": q.correctOptionIndexes,
  //               "answerKey": q.answerKey,
  //               "points": q.points,
  //               "required": true,
  //             },
  //           )
  //           .toList(),
  //     };
  //
  //     final data = await FunctionsService().exportToGoogleForms({
  //       "title": "Minimal Test",
  //       "description": "If this works, the API is fine",
  //       "questions": [],
  //     });
  //
  //     debugPrint('FUNCTION SUCCESS: $data');
  //   } catch (e, s) {
  //     debugPrint('FUNCTION ERROR: $e');
  //     debugPrint('$s');
  //   }
  // }

  Future<void> createGoogleForm({
    required BuildContext context,
    required PublishedQuizTemplate template,
  }) async {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    isLoading.value = true;

    try {
      UserModel userModel = UserModel.fromJson(userInfoCache);

      final payload = {
        'orgId': userModel.orgId, // pvamu
        'createdBy': userModel.uid,
        "title": template.title,
        "description": template.description,
        'templateId': template.id,
        "questions": template.items
            .map(
              (q) => {
                "type": q.type.name,
                "question": q.question,
                "options": q.options,
                "correctOptionIndexes": q.correctOptionIndexes,
                "answerKey": q.answerKey,
                "points": q.points,
                "required": true,
              },
            )
            .toList(),
      };

      print("payload: $payload");

      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode(payload),
      );

      final decoded = jsonDecode(response.body);

      if (decoded == null || decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response from Apps Script: ${response.body}");
      }

      final result = decoded;
      // 1. Check if the 'status' from your Apps Script is actually 'success'
      if (result['status'] == 'success' && result['publishedUrl'] != null) {
        String publishedUrl = result['publishedUrl'].toString();
        String editUrl = result['formUrl'].toString();

        print('Success! Form URL: $publishedUrl');

        // 2. Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Form Created"),
            content: Column(
              // Use Column instead of Row to prevent overflow
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Your Google Form is ready:"),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final Uri uri = Uri.parse(publishedUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    publishedUrl,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: publishedUrl));
                  Navigator.pop(context);
                  Get.snackbar(
                    "Copied",
                    "Link copied to clipboard!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.copy),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      } else {
        // 3. Handle the case where script failed or returned error status
        String errorMsg = result['message'] ?? "Unknown error occurred";
        print("Error from Script: $errorMsg");

        Get.snackbar(
          "Creation Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTemplates() {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    UserModel userModel = UserModel.fromJson(userInfoCache);

    return quizRepo
        .getTemplates(orgId: userModel.orgId)
        .then((templates) {
          publishedTemplates.assignAll(templates);
        })
        .catchError((e) {
          CustomSnackBar.errorSnackBar('Failed to load templates: $e');
        });
  }
}
