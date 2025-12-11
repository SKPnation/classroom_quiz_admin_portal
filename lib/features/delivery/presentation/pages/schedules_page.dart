import 'package:flutter/material.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  // ---- Design tokens ----
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _ink = Color(0xFF111827);
  static const _sub = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _purple = Color(0xFF6366F1);
  static const _radius = 16.0;

  // ---- Filter ----
  final _classOptions = const [
    'All Classes',
    'CSE 101 – A',
    'CSE 101 – B',
    'ENG 201',
    'SCI 240',
  ];
  String _selectedClass = 'All Classes';

  // ---- Fake data ----
  final List<_ScheduleRow> _all = [
    _ScheduleRow(
      className: 'CSE 101 – A',
      title: 'Weekly Quiz',
      status: ScheduleStatus.open,
      due: 'January 24',
    ),
    _ScheduleRow(
      className: 'CSE 101 – B',
      title: 'Midterm Exam',
      status: ScheduleStatus.inProgress,
      due: 'February 14',
    ),
    _ScheduleRow(
      className: 'ENG 201',
      title: 'Essay Assignment',
      status: ScheduleStatus.closed,
      due: 'January 17',
    ),
    _ScheduleRow(
      className: 'SCI 240',
      title: 'Lab Report',
      status: ScheduleStatus.closed,
      due: 'January 10',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final filtered = _all.where((row) {
      if (_selectedClass == 'All Classes') return true;
      return row.className == _selectedClass;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildTableCard(filtered, width),
        ],
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedules/Assignments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'View and manage quizzes assigned to your classes.',
          style: TextStyle(fontSize: 13, color: _sub),
        ),
      ],
    );
  }

  // ---------- Stats row ----------

  Widget _buildStatsRow() {
    final assignedClasses = _all.map((e) => e.className).toSet().length;
    final open = _all.where((e) => e.status == ScheduleStatus.open).length;
    final completed =
        _all.where((e) => e.status == ScheduleStatus.closed).length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard('Assigned Classes', assignedClasses.toString()),
        _statCard('Open Quizzes', open.toString()),
        _statCard('Completed Quizzes', completed.toString()),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return SizedBox(
      width: 220,
      child: Container(
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

  // ---------- Table card ----------

  Widget _buildTableCard(List<_ScheduleRow> rows, double width) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeaderRow(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFFF9FAFB),
                    ),
                    columnSpacing: 32,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('Class')),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Due')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: rows.map(_buildDataRow).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Filter + create button above the table
  Widget _buildTableHeaderRow() {
    return Row(
      children: [
        SizedBox(
          width: 220,
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(10),
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
        const Spacer(),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Create',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            onPressed: _onCreateSchedule,
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(_ScheduleRow row) {
    return DataRow(
      cells: [
        DataCell(Text(row.className)),
        DataCell(Text(row.title)),
        DataCell(_statusLabel(row.status)),
        DataCell(Text(row.due)),
        DataCell(_manageButton(row)),
      ],
    );
  }

  Widget _statusLabel(ScheduleStatus status) {
    Color color;
    String text;
    switch (status) {
      case ScheduleStatus.open:
        color = const Color(0xFF16A34A); // green
        text = 'Open';
        break;
      case ScheduleStatus.inProgress:
        color = const Color(0xFFF97316); // orange
        text = 'In Progress';
        break;
      case ScheduleStatus.closed:
        color = const Color(0xFF6B7280); // gray
        text = 'Closed';
        break;
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _manageButton(_ScheduleRow row) {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          side: const BorderSide(color: _purple),
          foregroundColor: _purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        onPressed: () => _onManage(row),
        child: const Text(
          'Manage',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ---------- Actions ----------

  void _onCreateSchedule() {
    // TODO: navigate to create-schedule / assignment builder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create schedule tapped')),
    );
  }

  void _onManage(_ScheduleRow row) {
    // TODO: open schedule details or edit page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Manage: ${row.title}')),
    );
  }
}

// ---------- Simple model ----------

enum ScheduleStatus { open, inProgress, closed }

class _ScheduleRow {
  final String className;
  final String title;
  final ScheduleStatus status;
  final String due;

  _ScheduleRow({
    required this.className,
    required this.title,
    required this.status,
    required this.due,
  });
}
