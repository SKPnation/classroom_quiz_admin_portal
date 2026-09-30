import 'dart:convert';

import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_snackbar.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/services/google_integration_service.dart';
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
    required bool fromEditor,
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

    await SettingsController.instance.loadDefaultIntegrations(userModel);

    final isCanvasConnected = SettingsController.instance
        .isIntegrationConnected('canvas');

    final isGoogleConnected = SettingsController.instance
        .isIntegrationConnected('google');

    debugPrint('Google connected: $isGoogleConnected');
    debugPrint('Canvas connected: $isCanvasConnected');

    if (!context.mounted) return;

    final result = await showDialog<PublishDestination>(
      context: context,
      builder: (dialogContext) {
        return PublishDestinationDialog(
          isCanvasConnected: isCanvasConnected,
          isGoogleConnected: isGoogleConnected,
        );
      },
    );

    if (result == null) return;

    if (fromEditor && qEditorController.quizItems.isEmpty) {
      CustomSnackBar.errorSnackBar(
        'Add at least one question before publishing.',
      );
      return;
    }

    if (!fromEditor && publishedQuiz.items.isEmpty) {
      CustomSnackBar.errorSnackBar(
        'This published quiz does not contain any questions.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final List<QuizItemModel> sourceItems;

      final String title;
      final String quizId;

      if (fromEditor) {
        final draftTitle = qEditorController.currentDraftTitle.value.trim();

        title = draftTitle.isEmpty ? 'Untitled Quiz' : draftTitle;

        quizId = qEditorController.currentDraftId.value.isNotEmpty
            ? qEditorController.currentDraftId.value
            : const Uuid().v4();

        sourceItems = qEditorController.cloneQuizItems(
          qEditorController.quizItems,
        );
      } else {
        title = publishedQuiz.title.trim().isEmpty
            ? 'Untitled Quiz'
            : publishedQuiz.title.trim();

        quizId = publishedQuiz.id.isNotEmpty
            ? publishedQuiz.id
            : const Uuid().v4();

        sourceItems = publishedQuiz.items
            .map(
              (item) => item.copyWith(
                options: List<String>.from(item.options),
                correctOptionIndexes: List<int>.from(item.correctOptionIndexes),
              ),
            )
            .toList();
      }

      if (sourceItems.isEmpty) {
        CustomSnackBar.errorSnackBar(
          'This quiz does not contain any questions.',
        );
        return;
      }

      final template = PublishedQuiz(
        id: quizId,
        title: title,
        description: publishedQuiz.description.isNotEmpty
            ? publishedQuiz.description
            : 'Published quiz',
        subject: publishedQuiz.subject.isNotEmpty
            ? publishedQuiz.subject
            : 'General',
        type: publishedQuiz.type.isNotEmpty ? publishedQuiz.type : 'Quiz',
        level: publishedQuiz.level.isNotEmpty ? publishedQuiz.level : 'Intro',
        items: sourceItems,
        publishedAt: DateTime.now(),
        tags: publishedQuiz.tags.isNotEmpty
            ? List<String>.from(publishedQuiz.tags)
            : const ['Published'],
        createdBy: publishedQuiz.createdBy.isNotEmpty
            ? publishedQuiz.createdBy
            : userModel.uid,
      );

      if (fromEditor) {
        debugPrint('Saving new quiz to templates collection');
        await publishTemplate(template);
      } else {
        debugPrint('Exporting existing quiz without saving a template');
      }

      // Create the Google Form.
      final updatedQuiz = await createGoogleForm(
        context: context,
        publishedQuiz: template,
        showLinkDialog: result != PublishDestination.googleFormsAndClassroom,
      );

      // Create the Google Classroom assignment.
      if (result == PublishDestination.googleFormsAndClassroom) {
        if (updatedQuiz?.formUrl == null ||
            updatedQuiz!.formUrl!.trim().isEmpty) {
          throw Exception(
            'Google Form was not created. Cannot sync to Classroom.',
          );
        }

        await syncToGoogleClassroom(
          context: context,
          publishedQuiz: updatedQuiz,
        );
      }

      // Sync to Canvas.
      if (result == PublishDestination.googleAndCanvas) {
        await syncToCanvas(context: context, publishedQuiz: template);
      }

      MenController.instance.changeActiveItemTo(
        Routes.publishedQuizzesDisplayName,
        Routes.publishedQuizzesRoute,
      );

      NavigationController.instance.navigateTo(Routes.publishedQuizzesRoute);

      CustomSnackBar.successSnackBar(body: 'Quiz published successfully.');
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions publish error:');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      debugPrint('Details: ${e.details}');

      final details = e.details is Map
          ? Map<String, dynamic>.from(e.details as Map)
          : <String, dynamic>{};

      final reason = details['reason']?.toString();

      final requiresGoogleReconnect =
          details['requiresGoogleReconnect'] == true;

      if (reason == 'GOOGLE_REAUTH_REQUIRED' || requiresGoogleReconnect) {
        if (!context.mounted) return;

        await showGoogleReconnectDialog(context, userModel);
        return;
      }

      if (reason == 'GOOGLE_NOT_CONNECTED') {
        CustomSnackBar.errorSnackBar(
          'Connect your Google account in Settings before publishing.',
        );
        return;
      }

      CustomSnackBar.errorSnackBar(e.message ?? 'Unable to publish the quiz.');
    } catch (e, stackTrace) {
      debugPrint('Publish failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      CustomSnackBar.errorSnackBar(
        'Unable to publish the quiz. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showGoogleReconnectDialog(
    BuildContext context,
    UserModel user,
  ) async {
    final shouldReconnect = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reconnect Google'),
          content: const Text(
            'Your Google connection has expired or is no longer valid. '
            'Disconnect and reconnect your Google account to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);

                MenController.instance.changeActiveItemTo(
                  Routes.settingsDisplayName,
                  Routes.settingsRoute,
                );

                NavigationController.instance.navigateTo(Routes.settingsRoute);
              },
              child: const Text('Disconnect & Reconnect'),
            ),
          ],
        );
      },
    );

    if (shouldReconnect != true || !context.mounted) return;

    try {
      isLoading.value = true;

      await GoogleIntegrationService().disconnectGoogle(orgId: user.orgId);
      if (!context.mounted) return;

      await GoogleIntegrationService().connectGoogle(orgId: user.orgId);

      CustomSnackBar.successSnackBar(
        body: 'Google reconnected successfully. Please publish again.',
      );
    } catch (e, stackTrace) {
      debugPrint('Google reconnect failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      CustomSnackBar.errorSnackBar(
        'Google could not be reconnected. Please reconnect from Settings.',
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

    if (userInfoCache == null) {
      CustomSnackBar.errorSnackBar(
        'User session not found. Please sign in again.',
      );
      return null;
    }

    isLoading.value = true;

    try {
      final userModel = UserModel.fromJson(userInfoCache);

      final payload = {
        'orgId': userModel.orgId,
        'publishedQuizId': publishedQuiz.id,
        'title': publishedQuiz.title,
        'description': publishedQuiz.description,
        'questions': publishedQuiz.items
            .map(
              (q) => {
                'type': q.type.name,
                'question': q.question,
                'options': q.options,
                'correctOptionIndexes': q.correctOptionIndexes,
                'answerKey': q.answerKey,
                'points': q.points,
                'required': true,
              },
            )
            .toList(),
      };

      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('createGoogleForm');

      // Pass the Map directly — do NOT jsonEncode. Callables handle serialization.
      final response = await callable.call(payload);

      final result = Map<String, dynamic>.from(response.data as Map);

      if (result['status'] == 'success' && result['publishedUrl'] != null) {
        final publishedUrl = result['publishedUrl'].toString();

        final updatedQuiz = publishedQuiz.copyWith(formUrl: publishedUrl);

        // No updateQuizFormUrl call needed — the Firebase Function already
        // wrote formUrl/formEditUrl to the Firestore doc server-side.

        if (showLinkDialog && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Form Created'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your Google Form is ready:'),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse(publishedUrl),
                        mode: LaunchMode.externalApplication,
                      );
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
                      'Copied',
                      'Link copied to clipboard!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }

        return updatedQuiz;
      } else {
        final errorMsg =
            result['message']?.toString() ?? 'Unknown error occurred';

        Get.snackbar(
          'Creation Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return null;
      }
    } on FirebaseFunctionsException {
      // Let publishWithDestinationDialog handle GOOGLE_NOT_CONNECTED /
      // GOOGLE_REAUTH_REQUIRED and show the reconnect dialog.
      rethrow;
    } catch (e) {
      debugPrint('Error creating Google Form: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
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

      // First call - no courseId, fetches list of classes
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

  void publish(PublishedQuiz t, BuildContext context, bool fromEditor) async {
    await publishWithDestinationDialog(
      context: context,
      publishedQuiz: t,
      fromEditor: fromEditor,
    );
  }
}
