import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/cardshell_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/list_row_widget.dart';
import 'package:flutter/material.dart';

class SecurityCard extends StatelessWidget {
  const SecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    const border = Color(0xFFE5E7EB);

    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 10),
          ListRow(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {},
          ),
          Divider(color: border, height: 1),
          ListRow(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
