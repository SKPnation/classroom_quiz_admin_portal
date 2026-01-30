import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  // ---- Design tokens ----
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = AppColors.purple;
  static const _radius = 16.0;

  // ---- Data ----
  final List<_StudentRow> _allStudents = [
    _StudentRow(
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      className: 'CSE 101 – A',
      lastActive: 'Today',
      status: StudentStatus.active,
    ),
    _StudentRow(
      name: 'Michael Lee',
      email: 'michael.lee@example.com',
      className: 'CSE 101 – A',
      lastActive: 'Yesterday',
      status: StudentStatus.active,
    ),
    _StudentRow(
      name: 'Sofia Torres',
      email: 'sofia.torres@example.com',
      className: 'CSE 101 – B',
      lastActive: '3 days ago',
      status: StudentStatus.inactive,
    ),
    _StudentRow(
      name: 'David Smith',
      email: 'david.smith@example.com',
      className: 'ENG 201',
      lastActive: '1 week ago',
      status: StudentStatus.invited,
    ),
  ];

  String _query = '';
  String _selectedClass = 'All Classes';

  final _classOptions = const [
    'All Classes',
    'CSE 101 – A',
    'CSE 101 – B',
    'ENG 201',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _allStudents.where((s) {
      final matchesClass =
          _selectedClass == 'All Classes' || s.className == _selectedClass;
      final matchesSearch = _query.isEmpty ||
          s.name.toLowerCase().contains(_query.toLowerCase()) ||
          s.email.toLowerCase().contains(_query.toLowerCase());
      return matchesClass && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 16),
          _buildFiltersRow(),
          const SizedBox(height: 16),
          _buildTableCard(filtered),
        ],
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeaderRow() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View and manage students across your classes.',
                style: TextStyle(fontSize: 13, color: _sub),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _purple),
              foregroundColor: _purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text(
              'Invite Students',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            onPressed: _onInviteStudents,
          ),
        ),
      ],
    );
  }

  // ---------- Filters (search + class dropdown) ----------

  Widget _buildFiltersRow() {
    return Row(
      children: [
        // Search
        SizedBox(
          width: 260,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon:
              const Icon(Icons.search_rounded, size: 18, color: _sub),
              hintText: 'Search by name or email',
              hintStyle: const TextStyle(fontSize: 13, color: _sub),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: _purple, width: 1.3),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() => _query = val),
          ),
        ),
        const SizedBox(width: 12),
        // Class filter
        SizedBox(
          width: 200,
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClass,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: const TextStyle(fontSize: 13, color: _ink),
                items: _classOptions
                    .map(
                      (c) => DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedClass = val);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Table card ----------

  Widget _buildTableCard(List<_StudentRow> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            offset: Offset(0, 1),
            color: Color.fromARGB(12, 0, 0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF9FAFB),
                ),
                columnSpacing: 32,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Last Active')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: rows.map(_buildDataRow).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(_StudentRow s) {
    return DataRow(
      cells: [
        DataCell(Text(s.name)),
        DataCell(Text(s.email)),
        DataCell(Text(s.className)),
        DataCell(Text(s.lastActive)),
        DataCell(_statusChip(s.status)),
        DataCell(_actionsButton(s)),
      ],
    );
  }

  Widget _statusChip(StudentStatus status) {
    late final String label;
    late final Color color;
    late final Color bg;

    switch (status) {
      case StudentStatus.active:
        label = 'Active';
        color = const Color(0xFF16A34A);
        bg = const Color(0xFFE4F8EC);
        break;
      case StudentStatus.inactive:
        label = 'Inactive';
        color = const Color(0xFF6B7280);
        bg = const Color(0xFFF3F4F6);
        break;
      case StudentStatus.invited:
        label = 'Invited';
        color = _purple;
        bg = const Color(0xFFEEF2FF);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _actionsButton(_StudentRow s) {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          foregroundColor: _purple,
          side: const BorderSide(color: _purple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: () => _onViewStudent(s),
        child: const Text(
          'View',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------- Actions ----------

  void _onInviteStudents() {
    // TODO: open invite modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite Students clicked')),
    );
  }

  void _onViewStudent(_StudentRow s) {
    // TODO: navigate to student detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View ${s.name}')),
    );
  }
}

// ---------- Model ----------

enum StudentStatus { active, inactive, invited }

class _StudentRow {
  final String name;
  final String email;
  final String className;
  final String lastActive;
  final StudentStatus status;

  _StudentRow({
    required this.name,
    required this.email,
    required this.className,
    required this.lastActive,
    required this.status,
  });
}
