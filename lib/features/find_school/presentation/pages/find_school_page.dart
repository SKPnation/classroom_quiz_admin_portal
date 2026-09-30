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
              // ── Asseska branding ──────────────────────────────────────
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/asseska_logo.png',
                  height: 80,
                  width: 80,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Asseska',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF534AB7),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'AI-powered quiz generation, automated grading and LMS integration',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // ─────────────────────────────────────────────────────────

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search for your school",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: c.onSearchChanged,
                  enabled: !c.loading.value,
                ),
              ),

              const SizedBox(height: 8),

              if (c.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    c.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              Expanded(
                child: c.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: c.schools.length,
                  itemBuilder: (_, index) {
                    final school = c.schools[index];
                    return SchoolListTile(
                      school: school,
                      onTap: () => c.selectSchool(school, context),
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