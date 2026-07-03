import 'package:classroom_quiz_admin_portal/features/resources/data/model/integration_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/user_model.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/cardshell_widget.dart';
import 'package:classroom_quiz_admin_portal/features/resources/presentation/widgets/integration_tile.dart';
import 'package:flutter/material.dart';

class IntegrationsCard extends StatelessWidget {
  const IntegrationsCard({super.key, required this.integrations});

  final List<IntegrationModel> integrations;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111827);
    const sub = Color(0xFF6B7280);

    return CardShell(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Integrations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Connect your favorite tools to enhance your workflow',
            style: TextStyle(fontSize: 12, color: sub),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: integrations.isEmpty
                ? const Center(
                    child: Text(
                      'No integrations available yet',
                      style: TextStyle(fontSize: 12, color: sub),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: integrations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return integrationTile(integrations[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
