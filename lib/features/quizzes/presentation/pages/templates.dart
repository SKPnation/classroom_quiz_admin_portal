import 'package:flutter/material.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  // ---- Design tokens ----
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = Color(0xFF6366F1);
  static const _chipBg = Color(0xFFF3F4FF);
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

  // ---- Fake template data ----
  final List<_Template> _allTemplates = [
    _Template(
      title: 'Weekly Check-In',
      description: '10-question formative assessment for weekly topics.',
      subject: 'Mathematics',
      type: 'Quiz',
      level: 'Intro',
      questionCount: 10,
      estimatedMinutes: 15,
      lastUsed: '2 days ago',
      tags: const ['Formative', 'Auto-graded'],
    ),
    _Template(
      title: 'Unit Test – Algebra',
      description: 'End-of-unit summative assessment on linear equations.',
      subject: 'Mathematics',
      type: 'Exam',
      level: 'Intermediate',
      questionCount: 25,
      estimatedMinutes: 45,
      lastUsed: '1 week ago',
      tags: const ['Summative', 'Mixed types'],
    ),
    _Template(
      title: 'Reading Comprehension',
      description: 'Passage-based questions with short answers and MCQs.',
      subject: 'English',
      type: 'Quiz',
      level: 'Intro',
      questionCount: 12,
      estimatedMinutes: 25,
      lastUsed: '3 days ago',
      tags: const ['Reading', 'Short answer'],
    ),
    _Template(
      title: 'Midterm Exam – General Science',
      description: 'Mixed MCQ, T/F, and short answer items.',
      subject: 'Science',
      type: 'Exam',
      level: 'Advanced',
      questionCount: 40,
      estimatedMinutes: 60,
      lastUsed: 'Last term',
      tags: const ['Midterm', 'Graded'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // ---- Apply filters & search ----
    final filtered = _allTemplates.where((t) {
      final subjectOk =
          _selectedSubject == 'All Subjects' || t.subject == _selectedSubject;
      final typeOk = _selectedType == 'All Types' || t.type == _selectedType;
      final levelOk =
          _selectedLevel == 'All Levels' || t.level == _selectedLevel;
      final searchOk = _search.isEmpty ||
          t.title.toLowerCase().contains(_search.toLowerCase()) ||
          t.description.toLowerCase().contains(_search.toLowerCase());
      return subjectOk && typeOk && levelOk && searchOk;
    }).toList();

    // Responsive columns for grid
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
          _buildSummaryRow(),
          const SizedBox(height: 16),
          _buildTemplatesGrid(filtered, columns),
        ],
      ),
    );
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
        onChanged: (v) => setState(() => _selectedSubject = v ?? _selectedSubject),
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
      SizedBox(
        height: 40,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'New Template',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          onPressed: _onCreateTemplate,
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
          Text(label,
              style: const TextStyle(fontSize: 11, color: _sub, height: 1.1)),
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
                        (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
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

  Widget _buildSummaryRow() {
    final total = _allTemplates.length;
    final quizCount = _allTemplates.where((t) => t.type == 'Quiz').length;
    final examCount = _allTemplates.where((t) => t.type == 'Exam').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _summaryCard('Total Templates', total.toString()),),
        SizedBox(width: 12),
        Expanded(child: _summaryCard('Quizzes', quizCount.toString()),),
        SizedBox(width: 12),
        Expanded(child: _summaryCard('Exams', examCount.toString()),),
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

  Widget _buildTemplatesGrid(List<_Template> templates, int columns) {
    if (templates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'No templates match your filters yet.',
          style: TextStyle(color: _sub),
        ),
      );
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
        return _templateCard(t);
      },
    );
  }

  Widget _templateCard(_Template t) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) => _onMenuAction(value, t),
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${t.subject} • ${t.type} • ${t.level}',
            style: const TextStyle(fontSize: 11, color: _sub),
          ),
          const SizedBox(height: 8),
          Text(
            t.description,
            style: const TextStyle(fontSize: 13, color: _ink),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '${t.questionCount} questions • ~${t.estimatedMinutes} min',
                style: const TextStyle(fontSize: 11, color: _sub),
              ),
              const Spacer(),
              Text(
                'Last used ${t.lastUsed}',
                style: const TextStyle(fontSize: 10, color: _sub),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: t.tags
                    .map(
                      (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 11, color: _ink),
                    ),
                  ),
                )
                    .toList(),
              ),
              const Spacer(),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _purple),
                    foregroundColor: _purple,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => _onUseTemplate(t),
                  child: const Text(
                    'Use template',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Actions ----------

  void _onCreateTemplate() {
    // TODO: navigate to a "Create Template" / quiz editor screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Template tapped')),
    );
  }

  void _onUseTemplate(_Template t) {
    // TODO: open quiz editor pre-filled from template
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Use template: ${t.title}')),
    );
  }

  void _onMenuAction(String action, _Template t) {
    // Stub actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action tapped for ${t.title}')),
    );
  }
}

// ---- Simple template model ----

class _Template {
  final String title;
  final String description;
  final String subject;
  final String type;
  final String level;
  final int questionCount;
  final int estimatedMinutes;
  final String lastUsed;
  final List<String> tags;

  _Template({
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.level,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.lastUsed,
    required this.tags,
  });
}
