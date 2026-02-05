import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/cardshell_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/list_row_widget.dart';
import 'package:flutter/material.dart';

class PreferencesCard extends StatelessWidget {
  const PreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    const sub = Color(0xFF6B7280);
    const border = Color(0xFFE5E7EB);

    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink),
          ),
          const SizedBox(height: 10),
          ListRow(
            icon: Icons.settings_outlined,
            title: 'Default Quiz Settings',
            onTap: () {},
          ),
          Divider(color: border, height: 1),
          ListRow(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            onTap: () {},
          ),
          Divider(color: border, height: 1),
          ListRow(
            icon: Icons.language_outlined,
            title: 'Time Zone',
            subtitle: 'America/Chicago',
            onTap: () {},
          ),
          const SizedBox(height: 4),
          const Text(
            'Tip: Defaults here can pre-fill Create Quiz and Scheduling.',
            style: TextStyle(fontSize: 12.5, color: sub),
          ),
        ],
      ),
    );
  }
}
