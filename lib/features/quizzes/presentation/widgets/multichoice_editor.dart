import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:flutter/material.dart';

class BuildMultiChoiceEditor extends StatefulWidget {
  const BuildMultiChoiceEditor({super.key, required this.q});

  final QuizItemModel q;

  @override
  State<BuildMultiChoiceEditor> createState() => _BuildMultiChoiceEditorState();
}

class _BuildMultiChoiceEditorState extends State<BuildMultiChoiceEditor> {
  // Helper to access the model shorter
  QuizItemModel get q => widget.q;

  @override
  Widget build(BuildContext context) {
    // Determine which index is currently "Correct"
    // Default to 0 if the list is empty
    int currentSelected = q.correctOptionIndexes.isNotEmpty
        ? q.correctOptionIndexes.first
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        RadioGroup<int>(
          groupValue: currentSelected,
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              // Update the list with the single selected index
              q.correctOptionIndexes.clear();
              q.correctOptionIndexes.add(val);
            });
          },
          child: Column(
            children: q.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final value = entry.value;
              // Use idx directly; no need to parse it as a string first
              final label = String.fromCharCode(65 + idx);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$label.',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        // Use a persistent controller or handle text carefully
                        controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
                        decoration: InputDecoration(
                          hintText: 'Option ${idx + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onChanged: (newText) {
                          q.options[idx] = newText;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Radio<int>(
                          value: idx,
                          groupValue: currentSelected,
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              // This uses the new setter in the model which
                              // safely reassigns the list: correctOptionIndexes = [val];
                              widget.q.correctIndex = val;
                            });
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text('Correct', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        if (q.options.length <= 1) return;
                        setState(() {
                          q.options.removeAt(idx);
                          // Reset correct index if we just deleted the selected one
                          if (currentSelected >= q.options.length) {
                            q.correctOptionIndexes.clear();
                            q.correctOptionIndexes.add(0);
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => q.options.add('')),
          child: const Text('+ Add option'),
        ),
      ],
    );
  }
}