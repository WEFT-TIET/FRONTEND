import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  String selectedSubgroup = '1B11';
  bool loading = true;

  // List all subgroups you support here
  final List<String> subgroups = [
    '1A11','1A12','1A13','1A14',
    '1B11','1B12','1B13','1B14','1B15','1B16','1B17','1B18','1B19','1B20',
    // … up to 1B66
  ];

  Map<String, String> subjectMap = {};
  Map<String, List<ClassSchedule>> timetableData = {};
  Map<String, bool> attendanceMap = {}; // key → present/absent

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadSubjectMap();
    await _loadTimetable(selectedSubgroup);
    await _loadAttendanceMap();
    setState(() => loading = false);
  }

  Future<void> _loadSubjectMap() async {
    final raw = await rootBundle.loadString('lib/core/assets/subjects.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw);
    subjectMap = {
      for (var code in jsonMap.keys) code: jsonMap[code]['name'] as String
    };
  }

  Future<void> _loadTimetable(String subgroup) async {
    final raw = await rootBundle.loadString('lib/core/assets/resultsTIMETABLEJULYTODEC25.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw);

    List<dynamic>? matrixRows;
    for (var yearBlock in jsonMap.values) {
      if (yearBlock is Map<String, dynamic> &&
          yearBlock.containsKey(subgroup)) {
        matrixRows = yearBlock[subgroup] as List<dynamic>;
        break;
      }
    }

    if (matrixRows == null || matrixRows.isEmpty) {
      timetableData = {};
      return;
    }

    final header = matrixRows[0] as List<dynamic>;
    final weekdays = header
        .skip(1)
        .map((cell) => (cell as Map<String, dynamic>)['course'] as String)
        .toList();

    final Map<String, List<ClassSchedule>> result = {};

    for (int r = 1; r < matrixRows.length; r++) {
      final row = matrixRows[r] as List<dynamic>;
      final time = (row[0] as Map<String, dynamic>)['course'] as String;

      for (int c = 1; c < row.length; c++) {
        final cell = row[c] as Map<String, dynamic>;
        final rawCourse = (cell['course'] as String).trim();
        if (rawCourse.isEmpty) continue;

        final code = rawCourse.split(' ').first;
        final name = subjectMap[code] ?? code;
        final day = weekdays[c - 1];

        result.putIfAbsent(day, () => []);
        final todayStr = DateFormat('yyyy-MM-dd').format(selectedDate);
        final now = DateTime.now();

        // Normalize today's date to midnight to ignore time
        final today = DateTime(now.year, now.month, now.day);

        // Parse classDateTime from selectedDate + time
        DateTime? classDateTime;
        try {
          classDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$todayStr $time');
        } catch (_) {
          classDateTime = null;
        }

        late final ClassStatus status;

        if (classDateTime == null) {
          status = ClassStatus.upcoming;
        } else if (selectedDate.isBefore(today)) {
          status = ClassStatus.completed;
        } else if (selectedDate.isAfter(today)) {
          status = ClassStatus.upcoming;
        } else {
          // selectedDate == today, so compare time now
          final diff = classDateTime.difference(now).inMinutes;
          if (diff < -10) {
            status = ClassStatus.completed;
          } else if (diff >= -10 && diff <= 30) {
            status = ClassStatus.live;
          } else {
            status = ClassStatus.upcoming;
          }
        }


        result[day]!.add(ClassSchedule(
          subject: name,
          time: time,
          status: status,
          present: 0,
          total: 30,
          subgroups: [subgroup],
        ));


      }
    }

    timetableData = result;
  }

  Future<void> _loadAttendanceMap() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('attendance') ?? '{}';
    final Map<String, dynamic> decoded = jsonDecode(saved);
    attendanceMap = decoded.map((k, v) => MapEntry(k, v as bool));
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
      _loadAttendanceMap().then((_) {
        setState(() => loading = false);
      });
    });
  }

  String _attendanceKey(ClassSchedule cls) {
    final date = DateFormat('yyyy-MM-dd').format(selectedDate);
    return '$date|$selectedSubgroup|${cls.subject}|${cls.time}';
  }

  void _markAttendance(ClassSchedule cls, bool present) async {
  final key = _attendanceKey(cls);
  final current = attendanceMap[key];

  setState(() {
    // If same button clicked again, remove the attendance entry
    if (current == present) {
      attendanceMap.remove(key);
    } else {
      attendanceMap[key] = present;
    }
  });

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('attendance', jsonEncode(attendanceMap));

  final message = attendanceMap.containsKey(key)
      ? (present ? 'Marked Present for ${cls.subject}' : 'Marked Absent for ${cls.subject}')
      : 'Cleared attendance for ${cls.subject}';

  final color = attendanceMap.containsKey(key)
      ? (present ? Colors.green : Colors.red)
      : Colors.grey;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance - TIET'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Subgroup dropdown
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubgroup,
                        dropdownColor: const Color(0xFF6B73FF),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        items: subgroups
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: _onSubgroupChanged,
                      ),
                    ),
                  ),
                ),

                // Date selector
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
                              fontSize: 20, fontWeight: FontWeight.bold),
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
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM dd, yyyy').format(selectedDate),
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _changeDate(-1),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEEE')
                          .format(selectedDate.subtract(const Duration(days: 1))),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Text('Swipe to navigate',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              GestureDetector(
                onTap: () => _changeDate(1),
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE')
                          .format(selectedDate.add(const Duration(days: 1))),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClassesList(String dayName) {
    final classes = timetableData[dayName] ?? [];
    final filtered =
        classes.where((c) => c.subgroups.contains(selectedSubgroup)).toList();

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
      itemBuilder: (_, i) => _buildClassCard(filtered[i]),
    );
  }

  Widget _buildClassCard(ClassSchedule cls) {
    final key = _attendanceKey(cls);
    final recorded = attendanceMap[key]; // true, false, or null

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
      default:
        borderColor = Colors.orange;
        statusChip = _statusChip('Upcoming', Colors.orange, Colors.white);
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
          Text(cls.time, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: cls.status != ClassStatus.upcoming
                        ? () => _markAttendance(cls, true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: recorded == true
                        ? const Icon(Icons.check, size: 16)
                        : const Text('Present', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: cls.status != ClassStatus.upcoming
                        ? () => _markAttendance(cls, false)
                        : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: recorded == false
                        ? const Icon(Icons.close, size: 16)
                        : const Text('Absent', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              if (recorded != null)
                Text(
                  recorded ? 'You were Present' : 'You were Absent',
                  style: TextStyle(
                      color: recorded ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
      );

  Widget _liveChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.circle, size: 6, color: Colors.white),
          SizedBox(width: 4),
          Text('Live Now',
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      );
}