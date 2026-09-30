import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFF6FF); // blue-50
    const ink = Color(0xFF1F2937); // gray-800

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      alignment: Alignment.center,
      child: const Text(
        'JD',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: ink,
        ),
      ),
    );
  }
}
