import 'package:classroom_quiz_admin_portal/core/navigation/app_routes.dart';
import 'package:classroom_quiz_admin_portal/core/navigation/navigation_controller.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/bottom_section.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/choice_card.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/header_title.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/hero_strip.dart';
import 'package:flutter/material.dart';

class CreateQuizPage extends StatelessWidget {
  CreateQuizPage({super.key});

  final navigationController = NavigationController.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        HeaderTitle(),
        const SizedBox(height: 16),

        // Hero with quick CTAs
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                HeroStrip(
                  onStartAI: () =>
                      navigationController.navigateTo(Routes.aiGeneratorRoute),
                  onStartManual: () =>
                      navigationController.navigateTo(Routes.quizEditorRoute),
                ),
                const SizedBox(height: 12),

                // Primary choice cards
                LayoutBuilder(
                  builder: (_, constraints) {
                    final twoUp = constraints.maxWidth >= 900;
                    final children = [
                      // AI card
                      ChoiceCard(
                        tag: 'ai generator',
                        title: 'Start with AI',
                        description:
                            'Paste a topic/syllabus, pick difficulty and outcomes; we’ll generate items you can review and edit.',
                        secondaryLabel: 'Learn more',
                        primaryLabel: 'Use AI',
                        onSecondary: () => navigationController.navigateTo(
                          Routes.aiGeneratorRoute,
                        ),
                        onPrimary: () => navigationController.navigateTo(
                          Routes.aiGeneratorRoute,
                        ),
                        leading: Icon(
                          Icons.auto_awesome,
                          color: AppColors.purple,
                        ),
                      ),

                      ChoiceCard(
                        tag: 'quiz editor',
                        title: 'Start manually',
                        description:
                            'Open the editor with a blank quiz. Add multiple choice, T/F, short answer, and essay items.',
                        secondaryLabel: 'Learn more',
                        primaryLabel: 'Open Editor',
                        // Manual card
                        onSecondary: () => navigationController.navigateTo(
                          Routes.quizEditorRoute,
                        ),
                        onPrimary: () => navigationController.navigateTo(
                          Routes.quizEditorRoute,
                        ),
                        leading: const Icon(
                          Icons.edit,
                          color: AppColors.purple,
                        ),
                      ),
                    ];

                    return twoUp
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: children[0]),
                              const SizedBox(width: 12),
                              Expanded(child: children[1]),
                            ],
                          )
                        : Column(
                            children: [
                              children[0],
                              const SizedBox(height: 12),
                              children[1],
                            ],
                          );
                  },
                ),
                const SizedBox(height: 12),

                // Quick actions & Defaults cards
                BottomSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
