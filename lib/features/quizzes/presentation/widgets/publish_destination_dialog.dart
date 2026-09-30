// ═══════════════════════════════════════════════════════════════════════
// NEW FILE: lib/features/quizzes/presentation/widgets/publish_destination_dialog.dart
// ═══════════════════════════════════════════════════════════════════════
//
// WHAT: The "Destination" dialog shown when publishing/syncing a quiz.
// Offers "Google Forms Only" (always available) and "Canvas + Google Forms"
// (disabled with a hint if Canvas isn't connected in Settings yet).
//
// This file defines the enum + dialog widget referenced by
// publishWithDestinationDialog() in published_quizzes_controller.dart.
// You can paste this into that same controller file (above or below the
// class), or keep it here as its own file and import it — either works,
// just make sure _PublishDestination and _PublishDestinationDialog are
// accessible from published_quizzes_controller.dart (drop the leading
// underscore if it's a separate file, since underscore = library-private).

import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';

enum PublishDestination {
  googleFormsOnly,
  googleFormsAndClassroom,
  googleAndCanvas,
}

class PublishDestinationDialog extends StatefulWidget {
  const PublishDestinationDialog({
    super.key,
    required this.isCanvasConnected,
    required this.isGoogleConnected,
  });

  final bool isCanvasConnected;
  final bool isGoogleConnected;

  @override
  State<PublishDestinationDialog> createState() =>
      _PublishDestinationDialogState();
}

class _PublishDestinationDialogState extends State<PublishDestinationDialog> {
  PublishDestination selected = PublishDestination.googleFormsOnly;

  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publish Quiz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose where to send this quiz.',
              style: TextStyle(fontSize: 12, color: _sub),
            ),
            const SizedBox(height: 16),

            _DestinationOption(
              title: 'Google Forms Only',
              subtitle:
                  'Students answer via a shareable link. No setup needed.',
              value: PublishDestination.googleFormsOnly,
              groupValue: selected,
              enabled: widget.isGoogleConnected,
              onChanged: (val) => setState(() => selected = val),
            ),
            const SizedBox(height: 10),
            _DestinationOption(
              title: 'Google Classroom + Google Forms',
              subtitle: widget.isGoogleConnected
                  ? 'Creates an assignment in Google Classroom with the form attached.'
                  : 'Connect Google Classroom in Settings first.',
              value: PublishDestination.googleFormsAndClassroom,
              groupValue: selected,
              enabled: widget.isGoogleConnected,
              onChanged: (val) => setState(() => selected = val),
            ),
            const SizedBox(height: 10),
            _DestinationOption(
              title: 'Canvas + Google Forms',
              subtitle: widget.isCanvasConnected
                  ? 'Also creates a matching Canvas assignment.'
                  : 'Connect Canvas in Settings first.',
              value: PublishDestination.googleAndCanvas,
              groupValue: selected,
              enabled: widget.isCanvasConnected,
              onChanged: (val) => setState(() => selected = val),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Publish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationOption extends StatelessWidget {
  const _DestinationOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final PublishDestination value;
  final PublishDestination groupValue;
  final bool enabled;
  final ValueChanged<PublishDestination> onChanged;

  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: enabled ? () => onChanged(value) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.purple : _border,
              width: isSelected ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 20,
                color: isSelected ? AppColors.purple : _sub,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: _sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
