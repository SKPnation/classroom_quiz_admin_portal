import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/resources/data/model/integration_model.dart';
import 'package:flutter/material.dart';

Widget integrationTile(
    IntegrationModel integration,
    ) {
  return InkWell(
    onTap: integration.onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [

          Icon(
            integration.icon,
            size: 34,
            color: AppColors.purple,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  integration.name,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                Text(
                  integration.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(
                      0xFF6B7280,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  integration.actionText,
                  style: const TextStyle(
                    color:
                    AppColors.purple,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (integration.connected)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFD1FAE5,
                ),
                borderRadius:
                BorderRadius.circular(
                  30,
                ),
              ),
              child: const Text(
                'Connected',
              ),
            ),

          const Icon(
            Icons.chevron_right_rounded,
          )
        ],
      ),
    ),
  );
}