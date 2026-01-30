import 'package:classroom_quiz_admin_portal/features/find_school/presentation/controllers/find_school_controller.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/presentation/widgets/school_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindSchoolPage extends StatelessWidget {
  const FindSchoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = FindSchoolController.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              // title, search bar, etc...
              TextField(
                decoration: InputDecoration(
                  hintText: "Search for your school",
                ),
                onChanged: c.onSearchChanged,
                enabled: !c.loading.value,
              ),

              if (c.errorMessage.isNotEmpty) Text(c.errorMessage.value),

              Expanded(
                child: c.loading.value
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: c.schools.length,
                        itemBuilder: (_, index) {
                          final school = c.schools[index];

                          return SchoolListTile(
                            school: school,
                            onTap: () => c.selectSchool(school),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
