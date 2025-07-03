import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  String selectedSubgroup = '1B1';
  PageController pageController = PageController();
  
  // Sample data structure for timetable
  Map<String, List<ClassSchedule>> timetableData = {
    'Monday': [
      ClassSchedule(
        subject: 'Mathematics',
        time: '8:00 - 9:40',
        status: ClassStatus.completed,
        present: 25,
        total: 30,
        subgroups: ['1B1', '1B2', '1B3'],
      ),
      ClassSchedule(
        subject: 'Physics Lab',
        time: '10:00 - 11:30',
        status: ClassStatus.live,
        present: 28,
        total: 30,
        subgroups: ['1B1', '1B4'],
      ),
      ClassSchedule(
        subject: 'Chemistry',
        time: '12:00 - 1:30',
        status: ClassStatus.upcoming,
        present: 26,
        total: 30,
        subgroups: ['1B1', '1B2'],
      ),
    ],
    'Tuesday': [
      ClassSchedule(
        subject: 'Manufacturing Process',
        time: '9:00 - 10:40',
        status: ClassStatus.completed,
        present: 23,
        total: 30,
        subgroups: ['1B1', '1B5'],
      ),
      ClassSchedule(
        subject: 'Physics Lecture',
        time: '9:45 - 10:30',
        status: ClassStatus.live,
        present: 28,
        total: 30,
        subgroups: ['1B1', '1B2', '1B3'],
      ),
      ClassSchedule(
        subject: 'Mathematics',
        time: '11:00 - 12:30',
        status: ClassStatus.upcoming,
        present: 25,
        total: 30,
        subgroups: ['1B1'],
      ),
      ClassSchedule(
        subject: 'Engineering Drawing',
        time: '2:00 - 3:30',
        status: ClassStatus.completed,
        present: 0,
        total: 30,
        subgroups: ['1B1', '1B6'],
      ),
    ],
    'Wednesday': [
      ClassSchedule(
        subject: 'Data Structures',
        time: '9:00 - 10:30',
        status: ClassStatus.upcoming,
        present: 0,
        total: 30,
        subgroups: ['1B1', '1B2'],
      ),
      ClassSchedule(
        subject: 'Computer Networks',
        time: '11:00 - 12:30',
        status: ClassStatus.upcoming,
        present: 0,
        total: 30,
        subgroups: ['1B1'],
      ),
    ],
    'Thursday': [
      ClassSchedule(
        subject: 'Software Engineering',
        time: '10:00 - 11:30',
        status: ClassStatus.upcoming,
        present: 0,
        total: 30,
        subgroups: ['1B1', '1B3'],
      ),
    ],
    'Friday': [
      ClassSchedule(
        subject: 'Industrial Management',
        time: '8:00 - 9:40',
        status: ClassStatus.completed,
        present: 27,
        total: 30,
        subgroups: ['1B1', '1B2'],
      ),
      ClassSchedule(
        subject: 'Quality Control',
        time: '10:00 - 11:30',
        status: ClassStatus.live,
        present: 23,
        total: 30,
        subgroups: ['1B1'],
      ),
      ClassSchedule(
        subject: 'Project Work',
        time: '2:00 - 4:00',
        status: ClassStatus.upcoming,
        present: 0,
        total: 30,
        subgroups: ['1B1', '1B4', '1B5'],
      ),
    ],
    'Saturday': [],
    'Sunday': [],
  };

  List<String> subgroups = [
    '1B1', '1B2', '1B3', '1B4', '1B5', '1B6', '1B7', '1B8', '1B9', '1B10',
    '1B11', '1B12', '1B13', '1B14', '1B15', '1B16', '1B17', '1B18', '1B19', '1B20',
    // Add more subgroups as needed up to 1B66
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance - TIET',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF9B59B6),
              Color(0xFFE74C3C),
            ],
          ),
        ),
        child: Column(
          children: [
            // Subgroup Selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSubgroup,
                  dropdownColor: const Color(0xFF6B73FF),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: subgroups.map((String subgroup) {
                    return DropdownMenuItem<String>(
                      value: subgroup,
                      child: Text(subgroup),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedSubgroup = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            
            // Date Header
            Container(
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
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, 
                                color: Colors.white, size: 16),
                            Text(
                              DateFormat('EEEE').format(
                                selectedDate.subtract(const Duration(days: 1))
                              ),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Swipe to navigate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _changeDate(1),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('EEEE').format(
                                selectedDate.add(const Duration(days: 1))
                              ),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, 
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Classes List
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
                    Expanded(
                      child: _buildClassesList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList() {
    String dayName = DateFormat('EEEE').format(selectedDate);
    List<ClassSchedule> classes = timetableData[dayName] ?? [];
    
    // Filter classes based on selected subgroup
    List<ClassSchedule> filteredClasses = classes
        .where((classItem) => classItem.subgroups.contains(selectedSubgroup))
        .toList();

    if (filteredClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled for\n$dayName',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredClasses.length,
      itemBuilder: (context, index) {
        return _buildClassCard(filteredClasses[index]);
      },
    );
  }

  Widget _buildClassCard(ClassSchedule classSchedule) {
    Color borderColor;
    Color statusColor;
    String statusText;
    Widget statusWidget;

    switch (classSchedule.status) {
      case ClassStatus.completed:
        borderColor = Colors.grey[300]!;
        statusColor = Colors.grey[600]!;
        statusText = 'Completed';
        statusWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
        break;
      case ClassStatus.live:
        borderColor = Colors.green;
        statusColor = Colors.green;
        statusText = 'Live Now';
        statusWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
        break;
      case ClassStatus.upcoming:
        borderColor = Colors.orange;
        statusColor = Colors.orange;
        statusText = 'Upcoming';
        statusWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: classSchedule.status == ClassStatus.live 
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
                  classSchedule.subject,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: classSchedule.status == ClassStatus.completed 
                        ? Colors.grey[600] 
                        : Colors.black87,
                  ),
                ),
              ),
              statusWidget,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            classSchedule.time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: classSchedule.status == ClassStatus.upcoming 
                        ? null 
                        : () => _markAttendance(classSchedule, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Present', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: classSchedule.status == ClassStatus.upcoming 
                        ? null 
                        : () => _markAttendance(classSchedule, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Absent', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              if (classSchedule.status != ClassStatus.upcoming)
                Text(
                  '${classSchedule.present}/${classSchedule.total}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  void _markAttendance(ClassSchedule classSchedule, bool isPresent) {
    // Handle attendance marking logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPresent 
              ? 'Marked as Present for ${classSchedule.subject}'
              : 'Marked as Absent for ${classSchedule.subject}',
        ),
        backgroundColor: isPresent ? Colors.green : Colors.red,
      ),
    );
  }
}

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

enum ClassStatus {
  completed,
  live,
  upcoming,
}