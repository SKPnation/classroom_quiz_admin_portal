import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_draft_model.dart';
import 'package:flutter/material.dart';

class DraftCard extends StatelessWidget {
  const DraftCard({super.key,
    required this.draft,
    required this.isActive,
    required this.onOpen,
    required this.onPublish,
    required this.onDuplicate,
    required this.onDelete,
  });

  final QuizDraftModel draft;
  final bool isActive;
  final VoidCallback onOpen;
  final VoidCallback onPublish;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? _blue : _border,
          width: isActive ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Draft',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'duplicate') onDuplicate();
                  if (value == 'delete') onDelete();
                  if (value == 'publish') onPublish();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'publish',
                    child: Text('Publish'),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text('Duplicate'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                child: const Icon(Icons.more_horiz, color: _sub),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            draft.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          MetaRow(label: 'Last edited', value: _formatDate(draft.savedAt)),
          const SizedBox(height: 6),
          MetaRow(label: 'Questions', value: '${draft.questionCount}'),
          const SizedBox(height: 6),
          MetaRow(label: 'Total points', value: '${draft.totalPoints}'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpen,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(isActive ? 'Open in Editor' : 'Continue Editing'),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final hour = dt.hour == 0
        ? 12
        : dt.hour > 12
        ? dt.hour - 12
        : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';

    return '${dt.month}/${dt.day}/${dt.year} • $hour:$minute $suffix';
  }
}

class MetaRow extends StatelessWidget {
  const MetaRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: _sub,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
          ),
        ),
      ],
    );
  }
}