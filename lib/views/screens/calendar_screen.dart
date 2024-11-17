import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'search_screen.dart';
import '../widgets/search_class_card.dart';
import '../../themes/app_colors.dart';
import 'cart_screen.dart';
import '../../models/class_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseReference _classRef = FirebaseDatabase.instance.ref().child('classes');
  final DatabaseReference _courseRef = FirebaseDatabase.instance.ref().child('courses');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');

  DateTime selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> classSchedule = {};

  void _processClassData(dynamic classData) {
    if (classData is Map) {
      final classDataMap = Map<String, dynamic>.from(classData);
      final dateString = classDataMap['date'] as String;
      classSchedule.putIfAbsent(dateString, () => []).add(classDataMap);
    }
  }

  Future<String> getCourseName(dynamic courseId) async {
    if (courseId == null) return 'Unknown Course';
    final snapshot = await _courseRef.child(courseId.toString()).get();
    return snapshot.exists ? (snapshot.value as Map)['name'] : 'Unknown Course';
  }

  Future<String> getInstructorName(dynamic instructorId) async {
    if (instructorId == null) return 'Unknown Instructor';
    final snapshot = await _instructorRef.child(instructorId.toString()).get();
    return snapshot.exists ? (snapshot.value as Map)['name'] : 'Unknown Instructor';
  }

  List<Map<String, dynamic>> _getClassesForSelectedDay() {
    final dateString = DateFormat('dd/MM/yyyy').format(selectedDate);
    return classSchedule[dateString] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF253334),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Calendar', style: TextStyle(color: Colors.white, fontFamily: 'AfacAdflux')),
        backgroundColor: const Color(0xFF253334),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen())),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _classRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading classes', style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data?.snapshot.value;
          classSchedule.clear();

          // Parse incoming data
          if (data is Map) {
            for (var value in data.values) {
              _processClassData(value);
            }
          } else if (data is List) {
            for (var classData in data) {
              _processClassData(classData);
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCalendarContainer(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Classes on ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'AfacAdflux'),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _getClassesForSelectedDay().length,
                    itemBuilder: (context, index) {
                      final classData = _getClassesForSelectedDay()[index];
                      return FutureBuilder<List<String>>(
                        future: Future.wait([
                          getCourseName(classData['courseId']),
                          getInstructorName(classData['instructor']),
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return ListTile(
                              title: Text(classData['name']),
                              subtitle: const Text('Error loading details'),
                            );
                          }

                          final courseName = snapshot.data![0];
                          final instructorName = snapshot.data![1];

                          return SearchClassCard(
                            classModel: ClassModel.fromJson(classData),
                            courseName: courseName,
                            instructorName: instructorName,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16.0),
      child: _buildCalendar(),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: selectedDate,
      selectedDayPredicate: (day) => isSameDay(day, selectedDate),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
        });
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF8D8767),
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: Color(0xFF4F4B3E),
          shape: BoxShape.circle,
        ),
        defaultDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD4BDAC), width: 0.5),
        ),
        defaultTextStyle: const TextStyle(
          color: Colors.black,
          fontFamily: 'AfacAdflux',
        ),
        todayTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'AfacAdflux',
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'AfacAdflux',
        ),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'AfacAdflux',
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final dateString = DateFormat('dd/MM/yyyy').format(date);
          if (classSchedule.containsKey(dateString)) {
            return Positioned(
              top: 7,
              left: 7,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}