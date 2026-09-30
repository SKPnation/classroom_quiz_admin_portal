import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDepartmentDialog(
    BuildContext context, {
      required ValueChanged<String> onSelected,
    }) {
  final departments = [
    'Computer Science',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Information Technology',
    'Mathematics',
    'Physics',
    'Other',
  ];

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.white,
      title: const Text('Select Department'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: departments.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final dept = departments[index];
            return ListTile(
              title: Text(dept),
              onTap: () {
                Get.back();
                onSelected(dept);
              },
            );
          },
        ),
      ),
    ),
  );
}
