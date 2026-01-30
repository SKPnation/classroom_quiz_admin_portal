import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  // ---- Design tokens ----
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = AppColors.purple;
  static const _radius = 16.0;

  final List<_ClassRow> _classes = const [
    _ClassRow(
      name: 'CSE 101 – A',
      code: 'CSE 101',
      students: 30,
      instructor: 'John Doe',
    ),
    _ClassRow(
      name: 'CSE 101 – B',
      code: 'CSE 101',
      students: 28,
      instructor: 'Michael Lee',
    ),
    _ClassRow(
      name: 'PHY 205',
      code: 'PHY 205',
      students: 25,
      instructor: 'Ashley Jones',
    ),
    _ClassRow(
      name: 'STA 300',
      code: 'STA 300',
      students: 32,
      instructor: 'Daniel Smith',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context),
          const SizedBox(height: 16),
          _buildTableCard(),
        ],
      ),
    );
  }

  // ---------- Header + "New Class" button ----------

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Classes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your courses and class sections.',
                style: TextStyle(fontSize: 13, color: _sub),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'New Class',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            onPressed: _onNewClass,
          ),
        ),
      ],
    );
  }

  // ---------- Main table card ----------

  Widget _buildTableCard() {
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
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Course Code')),
                  DataColumn(label: Text('Students')),
                  DataColumn(label: Text('Instructor')),
                ],
                rows: _classes.map(_buildDataRow).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(_ClassRow row) {
    return DataRow(
      cells: [
        DataCell(Text(row.name)),
        DataCell(Text(row.code)),
        DataCell(Text(row.students.toString())),
        DataCell(Text(row.instructor)),
      ],
    );
  }

  // ---------- Actions ----------

  void _onNewClass() {
    // TODO: open "Create Class" modal / route
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Class clicked')),
    );
  }
}

// Simple model for one row
class _ClassRow {
  final String name;
  final String code;
  final int students;
  final String instructor;

  const _ClassRow({
    required this.name,
    required this.code,
    required this.students,
    required this.instructor,
  });
}

