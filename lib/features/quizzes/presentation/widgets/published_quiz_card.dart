import 'package:classroom_quiz_admin_portal/core/data/local/get_store_keys.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/local_navigator.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/published_quizzes_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/controllers/settings_controller.dart';
import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/controllers/menu_controller.dart';
import 'package:classroom_quiz_admin_portal/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PublishedQuizCard extends StatelessWidget {
  PublishedQuizCard({super.key, required this.publishedQuiz});

  final PublishedQuiz publishedQuiz;

  // ---- Design tokens ----
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static final Color _chipBg = AppColors.purple.withValues(alpha: 0.12);
  static const _radius = 16.0;

  final pubQuizzesController = PublishedQuizzesController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(0, 1),
            color: Color.fromARGB(10, 0, 0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  publishedQuiz.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                color: Colors.white,
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(value: 'export', child: Text('Export')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'export') {
                    final userInfoCache = storage.read(GetStoreKeys.userKey);
                    final userModel = UserModel.fromJson(userInfoCache);
                    await SettingsController.instance.loadDefaultIntegrations(
                      userModel,
                    );

                    if (SettingsController.instance.isIntegrationConnected(
                      'google',
                    )) {
                      await PublishedQuizzesController.instance
                          .publishWithDestinationDialog(
                            context: context,
                            publishedQuiz: publishedQuiz,
                            fromEditor: false,
                          );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: AppColors.white,
                            title: const Text('Connect Google Account'),
                            content: const Text(
                              'You need to connect your Google account to publish quizzes. Do you want to connect now?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  //Auto scroll to end of integrations section in settings page
                                  SettingsController
                                          .instance
                                          .scrollToIntegrations
                                          .value =
                                      true;
                                  // Navigate to the settings page
                                  navigationController.navigateTo(
                                    Routes.settingsRoute,
                                  );
                                  MenController.instance.activePageRoute.value =
                                      Routes.settingsDisplayName;
                                },
                                child: const Text('Connect'),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    return;
                  } else if (value == 'delete') {
                    pubQuizzesController.deleteTemplate(publishedQuiz);
                    return;
                  }
                  _onMenuAction(value, publishedQuiz, context);
                },
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Text(
          //   '${t.subject} • ${t.type} • ${t.level}',
          //   style: const TextStyle(fontSize: 11, color: _sub),
          // ),
          // const SizedBox(height: 8),
          Text(
            publishedQuiz.description,
            style: const TextStyle(fontSize: 13, color: _ink),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '${publishedQuiz.questionCount} questions • ~${publishedQuiz.estimatedMinutes} min',
                style: const TextStyle(fontSize: 11, color: _sub),
              ),
              const Spacer(),
              Text(
                'Last used ${publishedQuiz.lastUsed}',
                style: const TextStyle(fontSize: 10, color: _sub),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: publishedQuiz.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _chipBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(fontSize: 11, color: _ink),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Spacer(),

              // SizedBox(
              //   height: 32,
              //   width: 160,
              //   child: CustomButton(
              //     radius: 100,
              //     borderColor: _purple,
              //     bgColor: Colors.transparent,
              //     onPressed: () => _onUseTemplate(t, context),
              //     text: 'Sync with Canvas',
              //     textColor: AppColors.purple,
              //     fontWeight: FontWeight.w600,
              //     showBorder: true,
              //     borderWidth: 1.5,
              //     fontSize: 12,
              //   ),
              //
              //   // OutlinedButton(
              //   //   style: OutlinedButton.styleFrom(
              //   //     side: const BorderSide(color: _purple),
              //   //     foregroundColor: _purple,
              //   //     padding: const EdgeInsets.symmetric(horizontal: 12),
              //   //     shape: RoundedRectangleBorder(
              //   //       borderRadius: BorderRadius.circular(999),
              //   //     ),
              //   //   ),
              //   //   onPressed: () => _onUseTemplate(t),
              //   //   child: const Text(
              //   //     'Use template',
              //   //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              //   //   ),
              //   // ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMenuAction(String action, PublishedQuiz t, BuildContext context) {
    // Stub actions
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action tapped for ${t.title}')));
  }
}
