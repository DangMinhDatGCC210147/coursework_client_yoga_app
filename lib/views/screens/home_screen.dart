import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/class_model.dart';
import '../widgets/home_class_card.dart';
import 'cart_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  static const Color backgroundColor = Color(0xFF253334);
  final DatabaseReference _classRef = FirebaseDatabase.instance.ref().child('classes');
  final DatabaseReference _courseRef = FirebaseDatabase.instance.ref().child('courses');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');

  Future<String> getCourseName(int courseId) async {
    final snapshot = await _courseRef.child(courseId.toString()).get();
    if (snapshot.exists) {
      final courseData = snapshot.value as Map;
      return courseData['name'] ?? 'Unknown Course';
    }
    return 'Unknown Course';
  }

  Future<String> getInstructorName(int instructorId) async {
    final snapshot = await _instructorRef.child(instructorId.toString()).get();
    if (snapshot.exists) {
      final instructorData = snapshot.value as Map;
      return instructorData['name'] ?? 'Unknown Instructor';
    }
    return 'Unknown Instructor';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<DatabaseEvent>(
        stream: _classRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading classes', style: TextStyle(color: Colors.white)),
            );
          }

          final data = snapshot.data?.snapshot.value;
          List<ClassModel> classList = [];

          // Parse data into classList if available
          if (data != null) {
            if (data is Map<dynamic, dynamic>) {
              classList = data.entries.map((entry) {
                final classData = Map<String, dynamic>.from(entry.value);
                return ClassModel.fromJson(classData);
              }).toList();
            } else if (data is List<dynamic>) {
              classList = data.map((classData) {
                if (classData is Map<dynamic, dynamic>) {
                  return ClassModel.fromJson(Map<String, dynamic>.from(classData));
                }
                return null;
              }).whereType<ClassModel>().toList();
            }
          }

          // Build the content with the class list (it will be empty if no data)
          return _buildContent(context, classList);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ClassModel> classList) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          _buildHeader(context),
          _buildWeekCalendar(),
          const SizedBox(height: 20),
          _buildUpcomingClassesHeader(),
          const SizedBox(height: 10),
          if (classList.isNotEmpty)
            _buildUpcomingClassesList(classList)
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No classes available',
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    'https://img.icons8.com/?size=100&id=23239&format=png&color=000000'),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning!',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'AfacAdflux'),
                  ),
                  Text(
                    'Hope you have an energetic day.',
                    style: TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'AfacAdflux'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final now = DateTime.now();
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = now.subtract(Duration(days: now.weekday - 1 - index));
          final isToday = day.day == now.day && day.month == now.month && day.year == now.year;

          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday ? Colors.black : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontFamily: 'AfacAdflux',
                    color: isToday ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                daysOfWeek[index],
                style: const TextStyle(color: Colors.white, fontFamily: 'AfacAdflux'),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUpcomingClassesHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Upcoming Classes!',
        style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'AfacAdflux'),
      ),
    );
  }

  Widget _buildUpcomingClassesList(List<ClassModel> classes) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateFormatter = DateFormat('dd/MM/yyyy');

    final upcomingClasses = classes.where((classModel) {
      try {
        final classDate = dateFormatter.parse(classModel.date);
        return classDate.isAfter(tomorrow);
      } catch (e) {
        return false;
      }
    }).toList();

    return SizedBox(
      height: 330,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: min(upcomingClasses.length, 5),
        itemBuilder: (context, index) {
          final classModel = upcomingClasses[index];
          return FutureBuilder<List<String>>(
            future: Future.wait([
              getCourseName(classModel.courseId),
              getInstructorName(classModel.instructor),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 350,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const SizedBox(
                  width: 400,
                  child: ListTile(
                    title: Text('Error loading class details'),
                  ),
                );
              }

              final courseName = snapshot.data![0];
              final instructorName = snapshot.data![1];

              return SizedBox(
                width: 400,
                child: HomeClassCard(
                  classModel: classModel,
                  courseName: courseName,
                  instructorName: instructorName,
                ),
              );
            },
          );
        },
      ),
    );
  }
}