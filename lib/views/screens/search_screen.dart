import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/class_model.dart';
import 'cart_screen.dart';
import '../widgets/search_class_card.dart';
import '../../themes/app_colors.dart';
import 'class_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? selectedDay;
  List<ClassModel> filteredClasses = [];

  final List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  final DatabaseReference _classRef = FirebaseDatabase.instance.ref().child('classes');
  final DatabaseReference _courseRef = FirebaseDatabase.instance.ref().child('courses');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');

  void searchClasses() async {
    if (selectedDay == null) return;

    final allClassesSnapshot = await _classRef.once();
    final data = allClassesSnapshot.snapshot.value;

    if (data is Map<dynamic, dynamic>) {
      List<ClassModel> allClasses = [];
      data.forEach((key, value) {
        allClasses.add(ClassModel.fromJson(Map<String, dynamic>.from(value)));
      });

      setState(() {
        filteredClasses = allClasses.where((classModel) {
          String dayOfWeek = getDayOfWeek(classModel.date);
          return dayOfWeek == selectedDay;
        }).toList();
      });
    } else if (data is List) {
      List<ClassModel> allClasses = [];
      for (var value in data) {
        if (value != null) {
          allClasses.add(ClassModel.fromJson(Map<String, dynamic>.from(value)));
        }
      }

      setState(() {
        filteredClasses = allClasses.where((classModel) {
          String dayOfWeek = getDayOfWeek(classModel.date);
          return dayOfWeek == selectedDay;
        }).toList();
      });
    }
  }

  String getDayOfWeek(String date) {
    DateTime parsedDate = DateTime.parse(date.split('/').reversed.join('-'));
    return daysOfWeek[parsedDate.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Classes', style: TextStyle(fontFamily: 'AfacAdflux')),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedDay,
                      hint: const Text(
                        'Select a day of the week',
                        style: TextStyle(color: Colors.white, fontFamily: 'AfacAdflux'),
                      ),
                      dropdownColor: AppColors.backgroundColor,
                      items: daysOfWeek.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day, style: const TextStyle(color: AppColors.white, fontFamily: 'AfacAdflux')),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: searchClasses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Search', style: TextStyle(fontSize: 16, fontFamily: 'AfacAdflux')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredClasses.isEmpty
                  ? const Center(child: Text('No classes available for this day.', style: TextStyle(fontSize: 16, fontFamily: 'AfacAdflux', color: AppColors.white)))
                  : ListView.builder(
                itemCount: filteredClasses.length,
                itemBuilder: (context, index) {
                  final classModel = filteredClasses[index];

                  return FutureBuilder<List<String>>(
                    future: Future.wait([
                      getCourseName(classModel.courseId),
                      getInstructorName(classModel.instructor),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading class details.'));
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
                        child: SearchClassCard(
                          classModel: classModel,
                          courseName: courseName,
                          instructorName: instructorName,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getCourseName(int courseId) async {
    final snapshot = await _courseRef.child(courseId.toString()).get();
    if (snapshot.exists) {
      final courseData = Map<String, dynamic>.from(snapshot.value as Map);
      return courseData['name'].toString();
    }
    return 'Unknown Course';
  }

  Future<String> getInstructorName(int instructorId) async {
    final snapshot = await _instructorRef.child(instructorId.toString()).get();
    if (snapshot.exists) {
      final instructorData = Map<String, dynamic>.from(snapshot.value as Map);
      return instructorData['name'].toString();
    }
    return 'Unknown Instructor';
  }
}