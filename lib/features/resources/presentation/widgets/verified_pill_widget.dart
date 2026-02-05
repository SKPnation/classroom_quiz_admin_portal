import 'package:flutter/material.dart';

class VerifiedPill extends StatelessWidget {
  const VerifiedPill({super.key});

  @override
  Widget build(BuildContext context) {
    const greenBg = Color(0xFFD1FAE5); // emerald-100
    const greenInk = Color(0xFF065F46); // emerald-800

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: greenBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Verified',
        style: TextStyle(
          color: greenInk,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
