import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';

class QuizEditorHeaderBtn extends StatelessWidget {
  const QuizEditorHeaderBtn({
    super.key,
    required this.label,
    this.primary = false,
    this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback? onTap;

  static const border = Color(0xFFE5E7EB);
  static const ink = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    final bg = primary ? AppColors.purple : Colors.white;
    final fg = primary ? Colors.white : ink;
    final borderColor = primary ? Colors.transparent : border;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
