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

class _AttendancePageState extends State<AttendancePage> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String selectedSubgroup = '1A11';
  bool loading = true;

  // Dynamic subgroups list - will be populated from JSON
  List<String> subgroups = [];

  Map<String, String> subjectMap = {};
  Map<String, List<ClassSchedule>> timetableData = {};
  Map<String, bool> attendanceMap = {}; // key → present/absent
  
  // Searchable dropdown state
  bool isDropdownOpen = false;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Day name mapping to handle different formats
  final Map<String, String> dayNameMapping = {
    'Monday': 'Monday',
    'Tuesday': 'Tuesday', 
    'Wednesday': 'Wednesday',
    'Thursday': 'Thursday',
    'Friday': 'Friday',
    'Saturday': 'Saturday',
    'Sunday': 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadAllData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _loadSubjectMap();
    await _loadSubgroups();
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

  Future<void> _loadSubgroups() async {
    final raw = await rootBundle.loadString('lib/core/assets/data.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw);
    
    // Extract all subgroup keys from the JSON
    subgroups = jsonMap.keys.toList();
    
    // Sort the subgroups for better organization
    subgroups.sort();
    
    print('Loaded ${subgroups.length} subgroups: ${subgroups.take(10).toList()}...');
    
    // Set default subgroup if current one is not in the list
    if (!subgroups.contains(selectedSubgroup) && subgroups.isNotEmpty) {
      selectedSubgroup = subgroups.first;
    }
  }

  Future<void> _loadTimetable(String subgroup) async {
    print('DEBUG: Loading timetable for subgroup: $subgroup, selectedDate: $selectedDate');
    final raw = await rootBundle.loadString('lib/core/assets/data.json');
    final Map<String, dynamic> jsonMap = jsonDecode(raw);

    // Debug: Print available subgroups
    print('Available subgroups: ${jsonMap.keys.toList()}');
    print('Looking for subgroup: $subgroup');

    // Check if the subgroup exists directly in the JSON
    if (!jsonMap.containsKey(subgroup)) {
      print('Subgroup $subgroup not found in JSON');
      timetableData = {};
      return;
    }

    print('Found subgroup $subgroup directly in JSON');

    final subgroupData = jsonMap[subgroup] as Map<String, dynamic>;
    final Map<String, List<ClassSchedule>> result = {};

    print('Subgroup data keys: ${subgroupData.keys.toList()}');

    // Process each day
    for (String day in subgroupData.keys) {
      final dayData = subgroupData[day] as Map<String, dynamic>;
      final List<ClassSchedule> dayClasses = [];

      // Process each time slot in the day
      for (String time in dayData.keys) {
        final classInfo = dayData[time] as List<dynamic>;
        
        print('Processing $day at $time: $classInfo');
        
        if (classInfo.length >= 4) {
          final courseCode = classInfo[0] as String;
          final venue = classInfo[1] as String;
          final subjectName = classInfo[2] as String;
          final classType = classInfo[3] as String;

          // Use subject name directly from JSON, fallback to subjectMap
          final name = subjectName.isNotEmpty ? subjectName : (subjectMap[courseCode] ?? courseCode);

          // Get current device date and time
          final now = DateTime.now();
          final currentDate = DateTime(now.year, now.month, now.day);
          final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

          // Debug prints to understand the date comparison
          print('DEBUG: Current date: $currentDate');
          print('DEBUG: Selected date: $selectedDateOnly');
          print('DEBUG: Is selected before current: ${selectedDateOnly.isBefore(currentDate)}');
          print('DEBUG: Is selected after current: ${selectedDateOnly.isAfter(currentDate)}');
          print('DEBUG: Is selected same as current: ${selectedDateOnly.isAtSameMomentAs(currentDate)}');

          // Parse classDateTime from selectedDate + time
          DateTime? classDateTime;
          try {
              final todayStr = DateFormat('yyyy-MM-dd').format(selectedDate);
              classDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse('$todayStr $time');
              print('DEBUG: Parsed classDateTime: $classDateTime');
          } catch (e) {
            print('DEBUG: Error parsing time: $e');
            classDateTime = null;
          }

          late final ClassStatus status;

          if (classDateTime == null) {
            // If we can't parse the time, default to upcoming
            status = ClassStatus.upcoming;
            print('DEBUG: Status set to upcoming (parsing failed)');
          } else {
            // FIRST: Compare the selected date with current date
            if (selectedDateOnly.isBefore(currentDate)) {
              // Past date - all classes are completed
              status = ClassStatus.completed;
              print('DEBUG: Status set to completed (past date)');
            } else if (selectedDateOnly.isAfter(currentDate)) {
              // Future date - all classes are upcoming
              status = ClassStatus.upcoming;
              print('DEBUG: Status set to upcoming (future date)');
            } else {
              // Same date (today) - use time-based logic
              final timeDifference = classDateTime.difference(now).inMinutes;
              print('DEBUG: Time difference in minutes: $timeDifference');
              
              if (timeDifference < -10) {
                // Class ended more than 10 minutes ago
                status = ClassStatus.completed;
                print('DEBUG: Status set to completed (time-based)');
              } else if (timeDifference >= -10 && timeDifference <= 30) {
                // Class is live (10 minutes before start to 30 minutes after start)
                status = ClassStatus.live;
                print('DEBUG: Status set to live');
              } else {
                // Class is more than 30 minutes in the future
                status = ClassStatus.upcoming;
                print('DEBUG: Status set to upcoming (time-based)');
              }
            }
          }

          dayClasses.add(ClassSchedule(
            subject: name,
            time: time,
            status: status,
            present: 0,
            total: 30,
            subgroups: [subgroup],
          ));
        }
      }

      if (dayClasses.isNotEmpty) {
        result[day] = dayClasses;
      }
    }

    print('Final timetable data: $result');
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
      loading = true;
    });
    print('DEBUG: Date changed to: $selectedDate');
    // Reload timetable data when date changes
    _loadTimetable(selectedSubgroup).then((_) {
      _loadAttendanceMap().then((_) {
        setState(() => loading = false);
      });
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

  void _toggleDropdown() {
    setState(() {
      isDropdownOpen = !isDropdownOpen;
      if (isDropdownOpen) {
        searchFocusNode.requestFocus();
      } else {
        searchController.clear();
        searchQuery = '';
      }
    });
    if (isDropdownOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE').format(selectedDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2D5A),
              Color(0xFF4A4E8A),
              Color(0xFF3A3E7A),
            ],
          ),
        ),
        child: SafeArea(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Column(
                  children: [
                    // Header with back button
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Attendance - TIET',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subgroup searchable dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchableDropdown(),
                    ),

                    const SizedBox(height: 16),

                    // Date selector
                    _buildDateSelector(),

                    const SizedBox(height: 24),

                    // Classes list
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF3A3E7A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE').format(selectedDate),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMMM dd, yyyy').format(selectedDate),
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _changeDate(-1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEE').format(selectedDate.subtract(const Duration(days: 1))),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Text('Swipe to navigate',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              GestureDetector(
                onTap: () => _changeDate(1),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('EEE').format(selectedDate.add(const Duration(days: 1))),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildClassesList(String dayName) {
    print('Looking for classes on: $dayName');
    print('Available days in timetable: ${timetableData.keys.toList()}');
    
    // Try to find the correct day name in the timetable data
    String? actualDayName;
    for (String key in timetableData.keys) {
      if (key.toLowerCase() == dayName.toLowerCase()) {
        actualDayName = key;
        break;
      }
    }
    
    print('Actual day name found: $actualDayName');
    
    final classes = timetableData[actualDayName ?? dayName] ?? [];
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
        borderColor = Color(0xFF10B981);
        statusChip = _liveChip();
        break;
      default:
        borderColor = Color(0xFFF59E0B);
        statusChip = _statusChip('Upcoming', Color(0xFFFEF3C7), Color(0xFFF59E0B));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: cls.status == ClassStatus.live
            ? Color(0xFF10B981).withOpacity(0.05)
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
                      backgroundColor: recorded == true ? Color(0xFF10B981) : Color(0xFF10B981).withOpacity(0.9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: recorded == true ? 0 : 2,
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
                      backgroundColor: recorded == false ? Color(0xFFEF4444) : Color(0xFFEF4444).withOpacity(0.9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: recorded == false ? 0 : 2,
                    ),
                    child: recorded == false
                        ? const Icon(Icons.close, size: 16)
                        : const Text('Absent', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              if (recorded != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: recorded ? Color(0xFF10B981).withOpacity(0.1) : Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recorded ? 'Present' : 'Absent',
                    style: TextStyle(
                      color: recorded ? Color(0xFF10B981) : Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
      );

  Widget _liveChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 6, color: Colors.white),
          SizedBox(width: 4),
          Text('Live Now',
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _buildSearchableDropdown() {
    // Filter subgroups based on search query
    final filteredSubgroups = subgroups
        .where((subgroup) => subgroup.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Selected subgroup display
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFF3A3E7A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.group,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedSubgroup,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isDropdownOpen ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Dropdown content with animation
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Calculate available height to prevent overflow
            final screenHeight = MediaQuery.of(context).size.height;
            final maxDropdownHeight = screenHeight * 0.4; // Use 40% of screen height
            
            return ClipRect(
              child: Container(
                height: _animation.value * maxDropdownHeight,
                child: _animation.value > 0
                    ? Container(
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF3A3E7A).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Search Bar
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  focusNode: searchFocusNode,
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Search subgroups...',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Subgroups list with constrained height
                            Flexible(
                              child: filteredSubgroups.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No subgroups found',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.only(bottom: 8),
                                      itemCount: filteredSubgroups.length,
                                      itemBuilder: (context, index) {
                                        final subgroup = filteredSubgroups[index];
                                        final isSelected = subgroup == selectedSubgroup;
                                        
                                        return GestureDetector(
                                          onTap: () {
                                            _onSubgroupChanged(subgroup);
                                            setState(() {
                                              isDropdownOpen = false;
                                              searchQuery = '';
                                              searchController.clear();
                                            });
                                            _animationController.reverse();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? Color(0xFF6366F1).withOpacity(0.2)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              border: isSelected
                                                  ? Border.all(color: Color(0xFF6366F1).withOpacity(0.5))
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: isSelected 
                                                        ? Color(0xFF6366F1)
                                                        : Colors.white.withOpacity(0.4),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    subgroup,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: isSelected 
                                                          ? Colors.white
                                                          : Colors.white.withOpacity(0.8),
                                                      fontWeight: isSelected 
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check,
                                                    color: Color(0xFF6366F1),
                                                    size: 18,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }
}