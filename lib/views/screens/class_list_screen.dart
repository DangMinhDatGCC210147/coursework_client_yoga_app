import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/class_model.dart';
import '../../themes/app_colors.dart';
import 'class_detail_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import '../widgets/class_card.dart';

class ClassListScreen extends StatelessWidget {
  final DatabaseReference _classRef = FirebaseDatabase.instance.ref().child('classes');
  final DatabaseReference _courseRef = FirebaseDatabase.instance.ref().child('courses');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');

  Future<String> getCourseName(int courseId) async {
    try {
      final snapshot = await _courseRef.child(courseId.toString()).get();
      if (snapshot.exists) {
        final courseData = Map<String, dynamic>.from(snapshot.value as Map);
        return courseData['name'].toString();
      }
    } catch (e) {
      print('Error fetching course name: $e');
    }
    return 'Unknown Course';
  }

  Future<String> getInstructorName(int instructorId) async {
    try {
      final snapshot = await _instructorRef.child(instructorId.toString()).get();
      if (snapshot.exists) {
        final instructorData = Map<String, dynamic>.from(snapshot.value as Map);
        return instructorData['name'].toString();
      }
    } catch (e) {
      print('Error fetching instructor name: $e');
    }
    return 'Unknown Instructor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class List', style: TextStyle(fontFamily: 'AfacAdflux')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
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
            return const Center(child: Text('Error loading classes'));
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No classes available', style: TextStyle(fontFamily: 'AfacAdflux', color: AppColors.white),));
          }

          List<ClassModel> classList = [];

          if (data is Map<dynamic, dynamic>) {
            classList = data.entries.map((entry) {
              final classData = Map<String, dynamic>.from(entry.value);
              return ClassModel.fromJson(classData);
            }).toList();
          }
          else if (data is List<dynamic>) {
            classList = data.map((classData) {
              if (classData is Map<dynamic, dynamic>) {
                return ClassModel.fromJson(Map<String, dynamic>.from(classData));
              } else {
                return null;
              }
            }).whereType<ClassModel>().toList(); // Lọc bỏ các phần tử null
          }
          else {
            return const Center(child: Text('Invalid data format'));
          }

          return ListView.builder(
            itemCount: classList.length,
            itemBuilder: (context, index) {
              final classModel = classList[index];

              return FutureBuilder<List<String>>(
                future: Future.wait([
                  getCourseName(classModel.courseId),
                  getInstructorName(classModel.instructor),
                ]),
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text(classModel.name),
                      subtitle: const Text('Error loading details'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return ListTile(
                      title: Text(classModel.name),
                      subtitle: const Text('No details available'),
                    );
                  }

                  final courseName = snapshot.data![0];
                  final instructorName = snapshot.data![1];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ClassDetailScreen(
                            classModel: classModel,
                          ),
                        ),
                      );
                    },
                    child: ClassCard(
                      classModel: classModel,
                      courseName: courseName,
                      instructorName: instructorName,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}