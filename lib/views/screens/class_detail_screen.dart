import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../themes/app_colors.dart';
import '../../models/class_model.dart';
import '../../models/course_model.dart';
import '../../models/instructor_model.dart';
import 'cart_screen.dart';
import 'search_screen.dart';

class ClassDetailScreen extends StatelessWidget {
  final ClassModel classModel;
  final DatabaseReference _courseRef = FirebaseDatabase.instance.ref().child('courses');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');
  final DatabaseReference _cartRef = FirebaseDatabase.instance.ref().child('cart');
  final DatabaseReference _bookingRef = FirebaseDatabase.instance.ref().child('bookings');
  final User? user = FirebaseAuth.instance.currentUser;

  ClassDetailScreen({Key? key, required this.classModel}) : super(key: key);

  Future<CourseModel?> getCourseDetails(int courseId) async {
    try {
      final snapshot = await _courseRef.child(courseId.toString()).get();
      if (snapshot.exists) {
        final courseData = Map<String, dynamic>.from(snapshot.value as Map);
        return CourseModel.fromJson(courseData);
      }
    } catch (e) {
      print('Error fetching course details: $e');
    }
    return null;
  }

  Future<InstructorModel?> getInstructorDetails(int instructorId) async {
    try {
      final snapshot = await _instructorRef.child(instructorId.toString()).get();
      if (snapshot.exists) {
        final instructorData = Map<String, dynamic>.from(snapshot.value as Map);
        return InstructorModel.fromJson(instructorData);
      }
    } catch (e) {
      print('Error fetching instructor details: $e');
    }
    return null;
  }

  Future<void> _addToCart(BuildContext context, ClassModel classModel) async {
    try {
      // Query the instructors node to get the instructor information of the logged in user
      final instructorSnapshot = await _instructorRef.orderByChild('email').equalTo(user?.email).once();

      if (instructorSnapshot.snapshot.value != null) {
        final instructorsMap = instructorSnapshot.snapshot.value as Map<dynamic, dynamic>;
        if (instructorsMap.isNotEmpty) {
          final instructorData = instructorsMap.values.first as Map<dynamic, dynamic>;
          final userId = instructorData['id'];

          // Query all bookings to check if the class is booked
          final bookingsSnapshot = await _bookingRef.once();
          if (bookingsSnapshot.snapshot.value != null) {
            final bookingsData = bookingsSnapshot.snapshot.value as Map<dynamic, dynamic>;

            bool isAlreadyBooked = false;
            for (var bookingEntry in bookingsData.entries) {
              final booking = bookingEntry.value;
              if (booking['userId'].toString() == userId.toString()) {
                final bookedClasses = List<String>.from(booking['classes'] ?? []);
                if (bookedClasses.contains(classModel.id.toString())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class already booked.')),
                  );
                  isAlreadyBooked = true;
                  break;
                }
              }
            }
            if (isAlreadyBooked) return;
          }

          // Check if the class is still available in the future
          DateTime classDate = DateFormat('dd/MM/yyyy').parse(classModel.date);
          DateTime now = DateTime.now();
          if (!classDate.isAfter(now)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Class has already ended or is today.')),
            );
            return;
          }

          // Check if the class is already in the cart
          final cartId = '${userId}_${classModel.id}';
          final snapshot = await _cartRef.child(cartId).once();

          if (snapshot.snapshot.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Class is already in cart.')),
            );
            return;
          }

          // Create cart item with `userId` from instructors
          final cartItem = {
            'idCart': cartId,
            'idClass': classModel.id,
            'userId': userId,
          };

          await _cartRef.child(cartId).set(cartItem).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Class added to cart!')),
            );
          }).catchError((error) {
            print('Failed to add class to cart: $error');
          });
        }
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding class to cart.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          classModel.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'AfacAdflux',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          getCourseDetails(classModel.courseId),
          getInstructorDetails(classModel.instructor),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null || snapshot.data!.contains(null)) {
            return const Center(
              child: Text(
                'Error loading details.',
                style: TextStyle(fontFamily: 'AfacAdflux'),
              ),
            );
          }

          final course = snapshot.data![0] as CourseModel;
          final instructor = snapshot.data![1] as InstructorModel;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/yoga_class_2.jpg',
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classModel.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'AfacAdflux',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'AfacAdflux',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.white70, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    instructor.name,
                                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'AfacAdflux'),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    instructor.email,
                                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'AfacAdflux'),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.email, color: Colors.white70, size: 20),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, color: Colors.white70, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    course.price,
                                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'AfacAdflux'),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    classModel.date,
                                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'AfacAdflux'),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timelapse, color: Colors.white70, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    course.courseTime,
                                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'AfacAdflux'),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    course.type,
                                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'AfacAdflux'),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.category_rounded, color: Colors.white70, size: 20),
                                ],
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24),
                          const Text(
                            'Description for course',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'AfacAdflux',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.description,
                            style: const TextStyle(color: Colors.white70, fontFamily: 'AfacAdflux'),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24),
                          const Text(
                            'Comments for class',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'AfacAdflux',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            classModel.comments?.isNotEmpty == true
                                ? classModel.comments!
                                : 'No comments available',
                            style: const TextStyle(color: Colors.white70, fontFamily: 'AfacAdflux'),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 15,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    _addToCart(context, classModel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Add Class To Cart',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'AfacAdflux',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}