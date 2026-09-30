import 'package:flutter/material.dart';

class SmallIconDot extends StatelessWidget {
  const SmallIconDot({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const sub = Color(0xFF6B7280);

    return Icon(icon, size: 18, color: sub);
  }
}
