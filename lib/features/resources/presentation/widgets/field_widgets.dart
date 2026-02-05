import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({super.key,
    required this.label,
    required this.hint,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 6),
        TextFieldShell(
          hintText: hint,
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }
}

class TextFieldShell extends StatelessWidget {
  const TextFieldShell({super.key,
    required this.hintText,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String hintText;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFE5E7EB);
    const sub = Color(0xFF6B7280);

    return TextField(
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: sub),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
      ),
    );
  }
}

class TextAreaShell extends StatelessWidget {
  const TextAreaShell({super.key, required this.hintText});
  final String hintText;

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFE5E7EB);
    const sub = Color(0xFF6B7280);

    return TextField(
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: sub),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
      ),
    );
  }
}
