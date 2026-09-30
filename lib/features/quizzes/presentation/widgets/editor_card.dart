import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/functions.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/quiz_editor_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/type_specific_fields_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildEditorCard extends StatefulWidget {
  const BuildEditorCard({super.key, required this.quizEditorController});

  final QuizEditorController quizEditorController;

  static const _card = Colors.white;
  static const _radius = 14.0;
  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF111827);

  @override
  State<BuildEditorCard> createState() => _BuildEditorCardState();
}

class _BuildEditorCardState extends State<BuildEditorCard> {
  late Worker _worker;

  @override
  void initState() {
    super.initState();

    _worker = ever(widget.quizEditorController.activeId, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateController();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateController();
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    super.dispose();
  }

  // This triggers when you switch to a different question
  // via the quizEditorController
  @override
  void didUpdateWidget(BuildEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quizEditorController.activeQuestion?.id !=
        oldWidget.quizEditorController.activeQuestion?.id) {
      _updateController();
    }
  }

  void _updateController() {
    final q = widget.quizEditorController.activeQuestion;
    if (q == null) return;

    final questionText = q.question;
    final pointsText = q.points.toString();

    if (widget.quizEditorController.questionController.text != questionText) {
      widget.quizEditorController.questionController.value =
          widget.quizEditorController.questionController.value.copyWith(
            text: questionText,
            selection: TextSelection.collapsed(offset: questionText.length),
            composing: TextRange.empty,
          );
    }

    if (widget.quizEditorController.pointsController.text != pointsText) {
      widget.quizEditorController.pointsController.value =
          widget.quizEditorController.pointsController.value.copyWith(
            text: pointsText,
            selection: TextSelection.collapsed(offset: pointsText.length),
            composing: TextRange.empty,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BuildEditorCard._card,
        borderRadius: BorderRadius.circular(BuildEditorCard._radius),
        border: Border.all(color: BuildEditorCard._border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(0, 1),
            color: Color.fromARGB(10, 0, 0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Obx(() {
          final q = widget.quizEditorController.activeQuestion;

          if (q == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Question',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BuildEditorCard._ink,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: BuildEditorCard._border),
              const SizedBox(height: 14),

              const Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BuildEditorCard._border),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: typeLabel(q.type),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    // THIS fixes the menu background
                    items: QuizItemType.values
                        .map(
                          (t) => DropdownMenuItem<String>(
                        value: typeLabel(t),
                        child: Text(
                          typeLabel(t),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        q.type = typeFromLabel(val);
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                'Question',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: widget.quizEditorController.questionController,
                maxLines: null,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter the question text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: BuildEditorCard._border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => saveFromControllers(),
              ),
              const SizedBox(height: 14),

              //QUESTION TYPE SPECIFIC FIELDS
              buildTypeSpecificFields(q, widget.quizEditorController),

              const SizedBox(height: 14),
              Row(
                children: [
                  // Points
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Points',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: widget.quizEditorController.pointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: BuildEditorCard._border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (val) {
                            final q = widget.quizEditorController.activeQuestion;
                            if (q == null) return;

                            q.points = int.tryParse(val) ?? 1;

                            widget.quizEditorController.quizItems.refresh();
                          },
                        ),                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Required
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Switch(
                              // value: q.required,
                              value: false,
                              activeThumbColor: AppColors.gold,
                              inactiveThumbColor: AppColors.grey[300],
                              onChanged: (val) {
                                setState(() {
                                  // q.required = val;
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            const Flexible(
                              child: Text(
                                'Students must answer',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BuildEditorCard._sub,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.transparent),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Expanded(
                  //   child: Text(
                  //     'Tip: Use ⌘/Ctrl+D to duplicate; ⌘/Ctrl+↑/↓ to reorder.',
                  //     style: TextStyle(fontSize: 11, color: BuildEditorCard._sub),
                  //   ),
                  // ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Total Points: ${widget.quizEditorController.totalPoints}',
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  void saveFromControllers() {
    final q = widget.quizEditorController.activeQuestion;
    if (q == null) return;

    q.question = widget.quizEditorController.questionController.text;
    q.points = int.tryParse(widget.quizEditorController.pointsController.text) ?? 1;

    widget.quizEditorController.quizItems.refresh();
  }
}
