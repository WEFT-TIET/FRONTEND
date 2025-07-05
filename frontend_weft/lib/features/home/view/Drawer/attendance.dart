import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum ClassStatus { completed, live, upcoming }

class ClassSchedule {
  final String subject;
  final String time;
  final ClassStatus status;
  final int present;
  final int total;
  final List<String> subgroups;

  ClassSchedule({
    required this.subject,
    required this.time,
    required this.status,
    required this.present,
    required this.total,
    required this.subgroups,
  });
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  String selectedSubgroup = '1B11';
  List<String> subgroups = [
    '1B11','1B12','1B13','1B14','1B15','1B16','1B17','1B18','1B21',
    // add up to 1B66...
  ];

  Map<String, String> subjectMap = {};
  Map<String, List<ClassSchedule>> timetableData = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadSubjectMap();
    await _loadTimetable(selectedSubgroup);
    setState(() => loading = false);
  }

  Future<void> _loadSubjectMap() async {
    final raw = await rootBundle.loadString('lib/core/assets/subjects.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw);
    subjectMap = {
      for (var code in jsonMap.keys)
        code: jsonMap[code]['name'] as String
    };
  }

  Future<void> _loadTimetable(String subgroup) async {
    final raw = await rootBundle.loadString('lib/core/assets/data.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw);

    List<List<dynamic>>? matrixRows;

    for (final yearBlock in jsonMap.values) {
      if (yearBlock is Map<String, dynamic> && yearBlock.containsKey(subgroup)) {
        matrixRows = List<List<dynamic>>.from(yearBlock[subgroup]);
        break;
      }
    }

    if (matrixRows == null || matrixRows.isEmpty) {
      timetableData = {};
      return;
    }

    // ...continue parsing logic as before...
  


    // Now it's safe to cast
    final List<dynamic> rows = matrixRows;
    // Proceed using rows...
  

    // First row is header: [ {"course":"Timings"}, {"course":"Monday"}, ... ]
    final header = matrixRows[0] as List<dynamic>;
    final weekdays = header
        .skip(1)
        .map((cell) => (cell as Map<String, dynamic>)['course'] as String)
        .toList();

    Map<String, List<ClassSchedule>> result = {};

    // Iterate each time-row
    for (var r = 1; r < matrixRows.length; r++) {
      final row = matrixRows[r] as List<dynamic>;
      final time = (row[0] as Map<String, dynamic>)['course'] as String;

      for (var c = 1; c < row.length; c++) {
        final cell = row[c] as Map<String, dynamic>;
        final rawCourse = (cell['course'] as String).trim();
        if (rawCourse.isEmpty) continue;

        // subject code is first token before space
        final code = rawCourse.split(' ').first;
        final name = subjectMap[code] ?? code;
        final day = weekdays[c - 1];

        result.putIfAbsent(day, () => []);
        result[day]!.add(ClassSchedule(
          subject: name,
          time: time,
          status: ClassStatus.upcoming,
          present: 0,
          total: 30,
          subgroups: [subgroup],
        ));
      }
    }

    timetableData = result;
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  void _onSubgroupChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      selectedSubgroup = newValue;
      loading = true;
    });
    _loadTimetable(newValue).then((_) {
      setState(() => loading = false);
    });
  }

  void _markAttendance(ClassSchedule cls, bool present) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          present
              ? 'Marked Present for ${cls.subject}'
              : 'Marked Absent for ${cls.subject}',
        ),
        backgroundColor: present ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance - TIET', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Subgroup selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubgroup,
                        dropdownColor: const Color(0xFF6B73FF),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        icon:
                            const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: subgroups
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: _onSubgroupChanged,
                      ),
                    ),
                  ),
                ),

                // Date header
                _buildDateSelector(),

                const SizedBox(height: 24),

                // Classes list
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Classes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(child: _buildClassesList(dayName)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE').format(selectedDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM dd, yyyy').format(selectedDate),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _changeDate(-1),
                child: Row(children: [
                  const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 16),
                  Text(
                    DateFormat('EEEE')
                        .format(selectedDate.subtract(const Duration(days: 1))),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14),
                  )
                ]),
              ),
              const Text('Swipe to navigate',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              GestureDetector(
                onTap: () => _changeDate(1),
                child: Row(children: [
                  Text(
                    DateFormat('EEEE')
                        .format(selectedDate.add(const Duration(days: 1))),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 16),
                ]),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClassesList(String dayName) {
    final classes = timetableData[dayName] ?? [];
    final filtered = classes
        .where((c) => c.subgroups.contains(selectedSubgroup))
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled for\n$dayName',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, idx) => _buildClassCard(filtered[idx]),
    );
  }

  Widget _buildClassCard(ClassSchedule cls) {
    Color borderColor;
    Widget statusChip;
    switch (cls.status) {
      case ClassStatus.completed:
        borderColor = Colors.grey[300]!;
        statusChip = _statusChip('Completed', Colors.grey[200]!, Colors.grey[600]!);
        break;
      case ClassStatus.live:
        borderColor = Colors.green;
        statusChip = _liveChip();
        break;
      case ClassStatus.upcoming:
      default:
        borderColor = Colors.orange;
        statusChip = _statusChip('Upcoming', Colors.orange, Colors.white);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: cls.status == ClassStatus.live
            ? Colors.green.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cls.subject,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cls.status == ClassStatus.completed
                        ? Colors.grey[600]
                        : Colors.black87,
                  ),
                ),
              ),
              statusChip,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cls.time,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ElevatedButton(
                  onPressed: cls.status == ClassStatus.upcoming
                      ? null
                      : () => _markAttendance(cls, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Present', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: cls.status == ClassStatus.upcoming
                      ? null
                      : () => _markAttendance(cls, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Absent', style: TextStyle(fontSize: 12)),
                ),
              ]),
              if (cls.status != ClassStatus.upcoming)
                Text(
                  '${cls.present}/${cls.total}',
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _liveChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.circle, size: 6, color: Colors.white),
        SizedBox(width: 4),
        Text('Live Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
