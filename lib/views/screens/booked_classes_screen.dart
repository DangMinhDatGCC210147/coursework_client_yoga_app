import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../views/widgets/class_card_booked.dart';
import '../../models/booking_model.dart';
import '../../models/class_model.dart';
import '../../models/course_model.dart';
import '../../models/instructor_model.dart';
import '../../themes/app_colors.dart';
import 'cart_screen.dart';
import 'class_detail_screen.dart';
import 'search_screen.dart';

class BookedClassesScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _bookingRef = FirebaseDatabase.instance.ref().child('bookings');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');

  BookedClassesScreen({Key? key}) : super(key: key);

  Future<int?> _getUserId() async {
    if (user == null) return null;

    final instructorSnapshot = await _instructorRef.orderByChild('email').equalTo(user!.email).once();
    if (instructorSnapshot.snapshot.exists) {
      final instructorData = (instructorSnapshot.snapshot.value as Map).values.first as Map;
      final dynamic userIdValue = instructorData['id'];
      return int.tryParse(userIdValue.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booked Classes',
          style: TextStyle(fontFamily: 'AfacAdflux'),
        ),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder<int?>(
        future: _getUserId(),
        builder: (context, userIdSnapshot) {
          if (userIdSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userIdSnapshot.hasError || userIdSnapshot.data == null) {
            return const Center(child: Text('Unable to load user information.'));
          }

          final userId = userIdSnapshot.data.toString();
          return StreamBuilder<DatabaseEvent>(
            stream: _bookingRef.orderByChild('userId').equalTo(userId).onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading booked classes.'));
              }

              final bookingsMap = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

              if (bookingsMap == null || bookingsMap.isEmpty) {
                return const Center(
                  child: Text(
                    'You have no booked classes.',
                    style: TextStyle(color: AppColors.white, fontFamily: 'AfacAdflux'),
                  ),
                );
              }

              final bookedClasses = bookingsMap.entries.map((entry) {
                final booking = entry.value;
                return BookingModel.fromJson(Map<String, dynamic>.from(booking));
              }).toList();

              return ListView.builder(
                itemCount: bookedClasses.length,
                itemBuilder: (context, index) {
                  final bookedClass = bookedClasses[index];

                  return FutureBuilder<List<ClassModel>>(
                    future: _getClassDetails(bookedClass.classes),
                    builder: (context, classSnapshot) {
                      if (classSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (classSnapshot.hasError) {
                        return const Center(child: Text('Error loading class details.'));
                      }

                      final classModels = classSnapshot.data;

                      return Column(
                        children: classModels!.map((classModel) {
                          return FutureBuilder<CourseModel>(
                            future: _getCourseDetails(classModel.courseId),
                            builder: (context, courseSnapshot) {
                              if (courseSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (courseSnapshot.hasError) {
                                return const Center(child: Text('Error loading course details.'));
                              }

                              final courseModel = courseSnapshot.data;

                              return FutureBuilder<InstructorModel>(
                                future: _getInstructorDetails(classModel.instructor),
                                builder: (context, instructorSnapshot) {
                                  if (instructorSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (instructorSnapshot.hasError) {
                                    return const Center(child: Text('Error loading instructor details.'));
                                  }

                                  final instructorModel = instructorSnapshot.data;

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
                                    child: ClassCardBooked(
                                      classModel: classModel,
                                      courseName: courseModel?.name ?? 'Course not found',
                                      instructorName: instructorModel?.name ?? 'Instructor not found',
                                      onCancel: () => _cancelBooking(bookedClass, classModel, context),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelBooking(BookingModel booking, ClassModel classModel, BuildContext context) async {
    final bool confirmCancel = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Cancellation"),
        content: Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (!confirmCancel) return;

    try {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime classDate = dateFormat.parse(classModel.date);
      final DateTime now = DateTime.now();

      if (classDate.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot cancel past classes.")),
        );
        return;
      }

      booking.classes.remove(classModel.id.toString());

      if (booking.classes.isEmpty) {
        await _bookingRef.child(booking.bookingId).remove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking cancelled successfully and booking entry removed.")),
        );
      } else {
        await _bookingRef.child(booking.bookingId).update(booking.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Class removed from booking successfully.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel booking: ${e.toString()}")),
      );
    }
  }

  Future<List<ClassModel>> _getClassDetails(List<String> classIds) async {
    List<ClassModel> classes = [];
    for (String id in classIds) {
      final snapshot = await FirebaseDatabase.instance.ref().child('classes').child(id).get();
      if (snapshot.exists) {
        final classData = Map<String, dynamic>.from(snapshot.value as Map);
        classes.add(ClassModel.fromJson(classData));
      }
    }
    return classes;
  }

  Future<CourseModel> _getCourseDetails(int courseId) async {
    final snapshot = await FirebaseDatabase.instance.ref().child('courses').child(courseId.toString()).get();
    final courseData = Map<String, dynamic>.from(snapshot.value as Map);
    return CourseModel.fromJson(courseData);
  }

  Future<InstructorModel> _getInstructorDetails(int instructorId) async {
    final snapshot = await _instructorRef.child(instructorId.toString()).get();
    final instructorData = Map<String, dynamic>.from(snapshot.value as Map);
    return InstructorModel.fromJson(instructorData);
  }
}