import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/repos/quiz_repo_impl.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/publish_destination_dialog.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class PublishedQuizzesController extends GetxController {
  static PublishedQuizzesController get instance =>
      Get.find<PublishedQuizzesController>();
  QuizRepoImpl quizRepo = QuizRepoImpl();
  final String scriptUrl = AppStrings.webAppUrl;
  RxBool isLoading = false.obs;

  final RxList<PublishedQuiz> publishedTemplates = <PublishedQuiz>[].obs;

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

  Future<void> publishTemplate(PublishedQuiz template) async {
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

    await quizRepo.addToTemplates(template: template, orgId: userModel.orgId);
  }

  void deleteTemplate(PublishedQuiz template) {
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

  Future<void> loadPublishedQuizzes() {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    UserModel userModel = UserModel.fromJson(userInfoCache);

    return quizRepo
        .getPublishedQuizzes(orgId: userModel.orgId)
        .then((publishedQuizzes) {
          publishedTemplates.assignAll(publishedQuizzes);
        })
        .catchError((e) {
          CustomSnackBar.errorSnackBar('Failed to load published quizzes: $e');
        });
  }

  Future<void> publishWithDestinationDialog({
    required BuildContext context,
    required PublishedQuiz publishedQuiz,
  }) async {
    final qEditorController = QuizEditorController.instance;

    final userInfoCache = storage.read(GetStoreKeys.userKey);
    if (userInfoCache == null) {
      CustomSnackBar.errorSnackBar(
        'User session not found. Please sign in again.',
      );
      return;
    }

    final userModel = UserModel.fromJson(userInfoCache);

    // Load integrations and wait for them before reading connected status
    await Future.delayed(Duration.zero, () async {
      await SettingsController.instance.loadDefaultIntegrations(userModel);
    });

    final isCanvasConnected = SettingsController.instance
        .isIntegrationConnected('canvas');
    final isGoogleConnected = SettingsController.instance
        .isIntegrationConnected('google');

    debugPrint('Google connected: $isGoogleConnected');
    debugPrint('Canvas connected: $isCanvasConnected');

    final result = await showDialog<PublishDestination>(
      context: context,
      builder: (context) => PublishDestinationDialog(
        isCanvasConnected: isCanvasConnected,
        isGoogleConnected: isGoogleConnected,
      ),
    );

    if (result == null) return;

    if (qEditorController.quizItems.isEmpty) {
      CustomSnackBar.errorSnackBar(
        'Add at least one question before publishing.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final title = qEditorController.currentDraftTitle.value.trim().isEmpty
          ? 'Untitled Quiz'
          : qEditorController.currentDraftTitle.value.trim();

      final publishedQuizId = qEditorController.currentDraftId.value.isNotEmpty
          ? qEditorController.currentDraftId.value
          : const Uuid().v4();

      final copiedItems = qEditorController.cloneQuizItems(
        qEditorController.quizItems,
      );

      final template = PublishedQuiz(
        id: publishedQuizId,
        title: title,
        description: publishedQuiz.description.isNotEmpty
            ? publishedQuiz.description
            : 'Published from quiz editor',
        subject: publishedQuiz.subject.isNotEmpty
            ? publishedQuiz.subject
            : 'General',
        type: publishedQuiz.type.isNotEmpty ? publishedQuiz.type : 'Quiz',
        level: publishedQuiz.level.isNotEmpty ? publishedQuiz.level : 'Intro',
        items: copiedItems,
        publishedAt: DateTime.now(),
        tags: const ['Published'],
        createdBy: userModel.uid,
      );

      // 1. Publish the template first
      await publishTemplate(template);

      // 2. Create the Google Form — suppress link dialog if going to Classroom
      final updatedQuiz = await createGoogleForm(
        context: context,
        publishedQuiz: template,
        showLinkDialog:
            result != PublishDestination.googleFormsAndClassroom, // ADD
      );

      // 3. Sync to Classroom
      if (result == PublishDestination.googleFormsAndClassroom) {
        if (updatedQuiz?.formUrl == null) {
          CustomSnackBar.errorSnackBar(
            'Google Form was not created. Cannot sync to Classroom.',
          );
          return;
        }
        await syncToGoogleClassroom(
          context: context,
          publishedQuiz: updatedQuiz!,
        );
      }

      if (result == PublishDestination.googleAndCanvas) {
        await syncToCanvas(context: context, publishedQuiz: template);
      }

      MenController.instance.changeActiveItemTo(
        Routes.publishedQuizzesDisplayName,
        Routes.publishedQuizzesRoute,
      );
      NavigationController.instance.navigateTo(Routes.publishedQuizzesRoute);

      CustomSnackBar.successSnackBar(body: 'Quiz published successfully.');
    } catch (e) {
      debugPrint('Publish failed: $e');

      Get.snackbar(
        'Publish Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Shows the "Destination" dialog (Google Forms Only vs Canvas + Google Forms),
  /// then runs the appropriate publish actions based on what the lecturer picks.
  /// This is the new entry point — wire your Publish/Sync button to call this
  /// instead of calling createGoogleForm() directly.
  Future<PublishedQuiz?> createGoogleForm({
    required BuildContext context,
    required PublishedQuiz publishedQuiz,
    bool showLinkDialog = true,
  }) async {
    final userInfoCache = storage.read(GetStoreKeys.userKey);

    isLoading.value = true;

    try {
      UserModel userModel = UserModel.fromJson(userInfoCache);

      final payload = {
        'orgId': userModel.orgId,
        'createdBy': userModel.uid,
        "title": publishedQuiz.title,
        "description": publishedQuiz.description,
        'publishedQuizId': publishedQuiz.id,
        "questions": publishedQuiz.items
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

      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode(payload),
      );

      final decoded = jsonDecode(response.body);

      if (decoded == null || decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response from Apps Script: ${response.body}");
      }

      final result = decoded;

      if (result['status'] == 'success' && result['publishedUrl'] != null) {
        String publishedUrl = result['publishedUrl'].toString();
        String editUrl = result['formUrl'].toString();

        final updatedQuiz = publishedQuiz.copyWith(formUrl: publishedUrl);

        await updateQuizFormUrl(
          quizId: publishedQuiz.id,
          orgId: userModel.orgId,
          formUrl: publishedUrl,
          editUrl: editUrl,
        );

        // Only show the link dialog if not going straight to Classroom
        if (showLinkDialog && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Form Created"),
              content: Column(
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
        }

        return updatedQuiz; // ← return updated quiz with formUrl
      } else {
        String errorMsg = result['message'] ?? "Unknown error occurred";

        Get.snackbar(
          "Creation Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return null; // ← form creation failed
      }
    } catch (e) {
      debugPrint('Error creating Google Form: $e');
      return null; // ← return null on error
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to persist formUrl on the Firestore quiz document
  Future<void> updateQuizFormUrl({
    required String quizId,
    required String orgId,
    required String formUrl,
    required String editUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('orgs')
        .doc(orgId)
        .collection('templates')
        .doc(quizId)
        .update({
          'formUrl': formUrl,
          'formEditUrl': editUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// STUB: Canvas sync is not implemented yet (OAuth flow + API calls are
  /// the next piece of work). This wires the UI/flow correctly now so the
  /// dialog and button work end-to-end once the real implementation lands.
  Future<void> syncToCanvas({
    required BuildContext context,
    required PublishedQuiz publishedQuiz,
  }) async {
    // TODO: Replace with real Canvas API call once OAuth flow is built.
    // Will need: stored Canvas access token for this user/org, selected
    // course + assignment, and a call to create/update the Canvas assignment
    // (see Canvas Assignments API).
    debugPrint(
      'TODO: syncToCanvas — would sync "${publishedQuiz.title}" to Canvas here.',
    );

    Get.snackbar(
      'Canvas Sync (Coming Soon)',
      'Canvas integration is not fully connected yet — Google Form was created successfully.',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  Future<void> syncToGoogleClassroom({
    required BuildContext context,
    required PublishedQuiz publishedQuiz,
  }) async {
    try {
      final org = storage.read(GetStoreKeys.orgKey);
      final orgId = org['code'].toString().toLowerCase();

      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('syncToGoogleClassroom');

      // First call — no courseId, fetches list of classes
      final coursesResult = await callable.call({
        'orgId': orgId,
        'quiz': {
          'id': publishedQuiz.id,
          'title': publishedQuiz.title,
          'description': publishedQuiz.description,
          'maxPoints': publishedQuiz.items.length,
          'formUrl': publishedQuiz.formUrl,
        },
      });

      if (!context.mounted) return;

      // If courses returned, show picker
      if (coursesResult.data['requiresCourseSelection'] == true) {
        final courses = List<Map>.from(coursesResult.data['courses']);

        final selectedCourse = await showDialog<Map>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text('Select a Class'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: courses.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(courses[i]['name']),
                  subtitle: Text(courses[i]['section'] ?? ''),
                  onTap: () => Navigator.pop(ctx, courses[i]),
                ),
              ),
            ),
          ),
        );

        if (selectedCourse == null || !context.mounted) return;

        // Second call — with selected courseId, creates the assignment
        final syncResult = await callable.call({
          'orgId': orgId,
          'courseId': selectedCourse['id'],
          'quiz': {
            'id': publishedQuiz.id,
            'title': publishedQuiz.title,
            'description': publishedQuiz.description,
            'maxPoints': publishedQuiz.items.length,
            'formUrl': publishedQuiz.formUrl,
          },
        });

        final classroomUrl = syncResult.data['classroomUrl'] as String?;

        if (context.mounted) {
          CustomSnackBar.successSnackBar(
            body: 'Assignment created in Google Classroom.',
          );

          if (classroomUrl != null) {
            await launchUrl(
              Uri.parse(classroomUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        CustomSnackBar.errorSnackBar(
          e.message ?? 'Failed to sync to Google Classroom.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.errorSnackBar('Something went wrong: $e');
      }
    }
  }

  void publish(PublishedQuiz t, BuildContext context) async{
    await publishWithDestinationDialog(
      context: context,
      publishedQuiz: t,
    );
  }
}
