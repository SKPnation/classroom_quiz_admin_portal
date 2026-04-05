import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/templates_controller.dart';
import 'package:flutter/material.dart';

class TemplateCard extends StatelessWidget {
  TemplateCard({super.key, required this.t});

  final PublishedQuizTemplate t;

  // ---- Design tokens ----
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = AppColors.purple;
  static final Color _chipBg = AppColors.purple.withValues(alpha: 0.12);
  static const _radius = 16.0;

  final templatesController = TemplatesController.instance;

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
                  t.title,
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
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(value: 'export_pdf', child: Text('Export to PDF')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'export_pdf') {
                    templatesController.exportTemplate(t);
                    return;
                  }else if(value == 'delete'){
                    templatesController.deleteTemplate(t.id);
                    return;
                  }
                  _onMenuAction(value, t, context);
                },
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${t.subject} • ${t.type} • ${t.level}',
            style: const TextStyle(fontSize: 11, color: _sub),
          ),
          const SizedBox(height: 8),
          Text(
            t.description,
            style: const TextStyle(fontSize: 13, color: _ink),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '${t.questionCount} questions • ~${t.estimatedMinutes} min',
                style: const TextStyle(fontSize: 11, color: _sub),
              ),
              const Spacer(),
              Text(
                'Last used ${t.lastUsed}',
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
                children: t.tags
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

              SizedBox(
                height: 32,
                width: 120,
                child: CustomButton(
                  radius: 100,
                  borderColor: _purple,
                  bgColor: Colors.transparent,
                  onPressed: () => _onUseTemplate(t, context),
                  text: 'Use template',
                  textColor: AppColors.purple,
                  fontWeight: FontWeight.w600,
                  showBorder: true,
                  borderWidth: 1.5,
                  fontSize: 12,
                ),

                // OutlinedButton(
                //   style: OutlinedButton.styleFrom(
                //     side: const BorderSide(color: _purple),
                //     foregroundColor: _purple,
                //     padding: const EdgeInsets.symmetric(horizontal: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(999),
                //     ),
                //   ),
                //   onPressed: () => _onUseTemplate(t),
                //   child: const Text(
                //     'Use template',
                //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                //   ),
                // ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMenuAction(String action, PublishedQuizTemplate t, BuildContext context) {
    // Stub actions
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action tapped for ${t.title}')));
  }

  void _onUseTemplate(PublishedQuizTemplate t, BuildContext context) {
    // TODO: open quiz editor pre-filled from template
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Use template: ${t.title}')));
  }
}
