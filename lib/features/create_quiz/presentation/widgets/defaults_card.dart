import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/card_scaffold.dart';
import 'package:classroom_quiz_admin_portal/features/create_quiz/presentation/widgets/defaults_setting_row.dart';
import 'package:flutter/material.dart';

class DefaultsCard extends StatelessWidget {
  const DefaultsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardScaffold(
      title: 'Defaults',
      child: Column(
        children: [
          DefaultsSettingRow(
            label: 'Time limit',
            child: Select(
              items: const ['No limit', '15 min', '30 min', '45 min', '60 min'],
            ),
          ),
          const SizedBox(height: 12),
          DefaultsSettingRow(
            label: 'Attempts',
            child: Select(items: const ['1', '2', '3', 'Unlimited']),
          ),
          const SizedBox(height: 12),
          DefaultsSettingRow(
            label: 'Shuffle questions',
            child: Switch(value: true, onChanged: (_) {}),
          ),
          const SizedBox(height: 12),
          DefaultsSettingRow(
            label: 'Grading scheme',
            child: Select(items: const ['Points', 'Percentage', 'Pass/Fail']),
          ),
          const SizedBox(height: 12),
          DefaultsSettingRow(
            label: 'Availability window',
            child: Select(
              items: const [
                'Always available',
                'Opens on start, closes on submit',
                'Custom date range…',
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomLeft,
            child: Btn(
              width: 160,
              label: 'Save as defaults',
              primary: true,
              onPressed: () {
                // Save preset defaults here
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Defaults saved')));
              },
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Applied to new quizzes (you can override in the editor).',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class Select extends StatefulWidget {
  const Select({super.key, required this.items});

  final List<String> items;

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  late String value = widget.items.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      items: widget.items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => value = v ?? value),
    );
  }
}

