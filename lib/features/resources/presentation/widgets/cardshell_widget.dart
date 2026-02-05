import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: child,
    );
  }
}
