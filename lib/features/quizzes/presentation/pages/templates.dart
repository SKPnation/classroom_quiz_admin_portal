import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_text.dart';
import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/data/models/published_quiz_template.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/controllers/templates_controller.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/template_card.dart';
import 'package:classroom_quiz_admin_portal/features/quizzes/presentation/widgets/templates_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final templatesController = TemplatesController.instance;

  // ---- Design tokens ----
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = AppColors.purple;
  static final Color _chipBg = AppColors.purple.withValues(alpha: 0.12);
  static const _radius = 16.0;

  // ---- Filters ----
  final _subjectOptions = const [
    'All Subjects',
    'Mathematics',
    'Science',
    'English',
    'History',
  ];
  final _typeOptions = const [
    'All Types',
    'Quiz',
    'Exam',
    'Practice',
    'Homework',
  ];
  final _levelOptions = const [
    'All Levels',
    'Intro',
    'Intermediate',
    'Advanced',
  ];

  String _selectedSubject = 'All Subjects';
  String _selectedType = 'All Types';
  String _selectedLevel = 'All Levels';
  String _search = '';
  

  @override
  Widget build(BuildContext context) {
    return Obx((){
      final allTemplates = templatesController.publishedTemplates;

      final filtered = allTemplates.where((t) {
        final subjectOk =
            _selectedSubject == 'All Subjects' || t.subject == _selectedSubject;
        final typeOk = _selectedType == 'All Types' || t.type == _selectedType;
        final levelOk =
            _selectedLevel == 'All Levels' || t.level == _selectedLevel;
        final searchOk =
            _search.isEmpty ||
                t.title.toLowerCase().contains(_search.toLowerCase()) ||
                t.description.toLowerCase().contains(_search.toLowerCase());

        return subjectOk && typeOk && levelOk && searchOk;
      }).toList();

      final width = MediaQuery.of(context).size.width;

      int columns = 3;
      if (width < 900) {
        columns = 1;
      } else if (width < 1200) {
        columns = 2;
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFiltersRow(width),
            const SizedBox(height: 16),
            _buildSummaryRow(filtered),
            const SizedBox(height: 16),
            _buildTemplatesGrid(filtered, columns),
          ],
        ),
      );
    });
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Templates',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Start new quizzes faster with reusable templates.',
          style: TextStyle(fontSize: 13, color: _sub),
        ),
      ],
    );
  }

  // ---------- Filters row ----------

  Widget _buildFiltersRow(double width) {
    final isNarrow = width < 900;

    final widgets = <Widget>[
      _dropdownFilter(
        label: 'Subject',
        value: _selectedSubject,
        items: _subjectOptions,
        onChanged: (v) =>
            setState(() => _selectedSubject = v ?? _selectedSubject),
      ),
      _dropdownFilter(
        label: 'Type',
        value: _selectedType,
        items: _typeOptions,
        onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
      ),
      _dropdownFilter(
        label: 'Level',
        value: _selectedLevel,
        items: _levelOptions,
        onChanged: (v) => setState(() => _selectedLevel = v ?? _selectedLevel),
      ),
      Expanded(
        child: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18),
              hintText: 'Search templates',
              hintStyle: const TextStyle(fontSize: 13, color: _sub),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) => setState(() => _search = val),
          ),
        ),
      ),
      const SizedBox(width: 8),

      Btn(
        width: 165,
        primary: true,
        onPressed: _onCreateTemplate,
        child: Row(
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.white),
            const SizedBox(width: 4),
            const CustomText(text: 'New Template', color: AppColors.white),
          ],
        ),
      ),
    ];

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widgets.take(3).toList(), // 3 dropdowns
          ),
          const SizedBox(height: 8),
          Row(
            children: widgets.sublist(3), // search + button
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: 190, child: widgets[0]),
        const SizedBox(width: 8),
        SizedBox(width: 160, child: widgets[1]),
        const SizedBox(width: 8),
        SizedBox(width: 160, child: widgets[2]),
        const SizedBox(width: 8),
        widgets[3],
        widgets[4],
        widgets[5],
      ],
    );
  }

  Widget _dropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _sub, height: 1.1),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  style: const TextStyle(fontSize: 13, color: _ink),
                  items: items
                      .map(
                        (e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Summary row (optional stats) ----------

  Widget _buildSummaryRow(List<PublishedQuizTemplate> templates) {
    final total = templates.length;
    final quizCount = templates.where((t) => t.type == 'Quiz').length;
    final examCount = templates.where((t) => t.type == 'Exam').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _summaryCard('Total Templates', total.toString())),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Quizzes', quizCount.toString())),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard('Exams', examCount.toString())),
      ],
    );
  }

  Widget _summaryCard(String label, String value) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(0, 1),
              color: Color.fromARGB(10, 0, 0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: _sub)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Templates grid ----------

  Widget _buildTemplatesGrid(List<PublishedQuizTemplate> templates, int columns) {
    if (templates.isEmpty) {
      return TemplatesGrid(templates: templates, columns: columns);
    }

    return GridView.builder(
      itemCount: templates.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: 210,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final t = templates[index];
        return TemplateCard( t: t,);
      },
    );
  }

  // ---------- Actions ----------

  void _onCreateTemplate() {
    // TODO: navigate to a "Create Template" / quiz editor screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('New Template tapped')));
  }



 
}
