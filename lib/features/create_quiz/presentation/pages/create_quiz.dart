import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/bottom_section.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/choice_card.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/header_title.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/hero_strip.dart';
import 'package:flutter/material.dart';

class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        HeaderTitle(),
        const SizedBox(height: 16),

        // Hero with quick CTAs
        Expanded(child:
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              HeroStrip(
                onStartAI: () {
                  //Get.toNamed('/ai_generator')
                },
                onStartManual: () {
                  //Get.toNamed('/quiz_editor')
                },
              ),
              const SizedBox(height: 12),

              // Primary choice cards
              LayoutBuilder(
                builder: (_, constraints) {
                  final twoUp = constraints.maxWidth >= 900;
                  final children = [
                    ChoiceCard(
                      tag: 'ai generator',
                      title: 'Start with AI',
                      description:
                      'Paste a topic/syllabus, pick difficulty and outcomes; we’ll generate items you can review and edit.',
                      secondaryLabel: 'Learn more',
                      primaryLabel: 'Use AI',
                      onSecondary: () => {
                        // Get.toNamed('/ai_generator')
                      },
                      onPrimary: () {
                        //Get.toNamed('/ai_generator')
                      },
                      leading: Icon(Icons.auto_awesome, color: AppColors.purple),
                    ),
                    ChoiceCard(
                      tag: 'quiz editor',
                      title: 'Start manually',
                      description:
                      'Open the editor with a blank quiz. Add multiple choice, T/F, short answer, and essay items.',
                      secondaryLabel: 'Learn more',
                      primaryLabel: 'Open Editor',
                      onSecondary: () {
                        //Get.toNamed('/quiz_editor')
                      },
                      onPrimary: () {
                        //Get.toNamed('/quiz_editor')
                      },
                      leading: const Icon(Icons.edit, color: AppColors.purple),
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
              BottomSection()
            ],
          ),
        ))
      ],
    );
  }
}
