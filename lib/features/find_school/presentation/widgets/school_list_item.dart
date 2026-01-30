import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:flutter/material.dart';

class SchoolListTile extends StatelessWidget {
  final SchoolModel school;
  final VoidCallback onTap;

  const SchoolListTile({super.key, required this.school, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitleText =
        school.code ??
        (school.allowedDomains.isNotEmpty ? school.allowedDomains.first : null);

    return ListTile(
      leading: CircleAvatar(
        child: ClipOval(
          child: (school.logoUrl != null && school.logoUrl!.isNotEmpty)
              ? Image.network(
                  school.logoUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Center(
                      child: Text(
                        school.name.isNotEmpty
                            ? school.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    school.name.isNotEmpty ? school.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),

      title: Text(
        school.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitleText != null ? Text(subtitleText) : null,
      onTap: onTap,
    );
  }
}
