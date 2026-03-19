import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/quiz_item_model.dart';
import 'package:flutter/material.dart';

class BuildTrueFalseEditor extends StatefulWidget {
  const BuildTrueFalseEditor({super.key, required this.q});

  final QuizItemModel q;

  @override
  State<BuildTrueFalseEditor> createState() => _BuildTrueFalseEditorState();
}

class _BuildTrueFalseEditorState extends State<BuildTrueFalseEditor> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answer',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        // Row(
        //   children: [
        //     Expanded(
        //       child: ChoiceChip(
        //         label: const Text('True'),
        //         selected: widget.q.tfAnswer,
        //         onSelected: (val) {
        //           if (val) {
        //             setState(() => q.tfAnswer = true);
        //           }
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 8),
        //     Expanded(
        //       child: ChoiceChip(
        //         label: const Text('False'),
        //         selected: !widget.q.tfAnswer,
        //         onSelected: (val) {
        //           if (val) {
        //             setState(() => widget.q.tfAnswer = false);
        //           }
        //         },
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
