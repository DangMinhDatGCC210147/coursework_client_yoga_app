import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/cart_model.dart';
import '../../models/class_model.dart';
import '../../models/course_model.dart';
import '../../models/instructor_model.dart';
import '../../models/booking_model.dart';
import '../widgets/class_card_cart.dart';
import 'class_detail_screen.dart';
import 'search_screen.dart';
import '../../themes/app_colors.dart';

class CartScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseReference _cartRef = FirebaseDatabase.instance.ref().child('cart');
  final DatabaseReference _classRef = FirebaseDatabase.instance.ref().child('classes');
  final DatabaseReference _courseRef = FirebaseDatabase.instance.ref().child('courses');
  final DatabaseReference _instructorRef = FirebaseDatabase.instance.ref().child('instructors');
  final DatabaseReference _bookingRef = FirebaseDatabase.instance.ref().child('bookings');

  CartScreen({Key? key}) : super(key: key);

  Future<String?> _getUserId() async {
    if (user == null) {
      print("User is null");
      return null;
    }

    try {
      final instructorSnapshot = await _instructorRef.orderByChild('email').equalTo(user!.email).once();
      if (instructorSnapshot.snapshot.value != null) {
        final instructorsMap = instructorSnapshot.snapshot.value as Map<dynamic, dynamic>;
        if (instructorsMap.isNotEmpty) {
          final instructorData = instructorsMap.values.first as Map<dynamic, dynamic>;
          final dynamic userIdValue = instructorData['id'];
          final userId = userIdValue is int ? userIdValue.toString() : userIdValue as String;
          return userId;
        }
      }
    } catch (e) {
      print("Error fetching userId from instructors: $e");
    }
    return null;
  }

  Future<void> _removeFromCart(String cartItemKey) async {
    try {
      await _cartRef.child(cartItemKey).remove();
      print("Successfully removed cart item with ID $cartItemKey");
    } catch (error) {
      print("Failed to remove cart item with ID $cartItemKey: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, userIdSnapshot) {
        if (userIdSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userIdSnapshot.hasError || userIdSnapshot.data == null) {
          return const Center(child: Text('Unable to load user cart.'));
        }

        final userId = userIdSnapshot.data.toString();
        print("User ID for querying cart: $userId");

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart', style: TextStyle(fontFamily: 'AfacAdflux')),
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
            ],
          ),
          body: StreamBuilder<DatabaseEvent>(
            stream: _cartRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading cart items.'));
              }

              final cartItemsMap = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

              if (cartItemsMap == null || cartItemsMap.isEmpty) {
                return const Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(color: AppColors.white, fontSize: 18, fontFamily: 'AfacAdflux'),
                  ),
                );
              }

              final cartItems = cartItemsMap.entries
                  .where((entry) {
                final key = entry.key as String;
                final keyParts = key.split('_');
                return keyParts.isNotEmpty && keyParts[0] == userId;
              })
                  .map((entry) {
                final cartItem = entry.value;
                return CartModel.fromJson(Map<String, dynamic>.from(cartItem));
              }).toList();

              if (cartItems.isEmpty) {
                return const Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(color: AppColors.white, fontSize: 18, fontFamily: 'AfacAdflux'),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];

                        return FutureBuilder<ClassModel>(
                          future: _getClassDetails(item.idClass),
                          builder: (context, classSnapshot) {
                            if (classSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (classSnapshot.hasError) {
                              return const Center(child: Text('Error loading class details.'));
                            }

                            final classModel = classSnapshot.data;

                            if (classModel == null) {
                              return const Center(child: Text('Class not found.'));
                            }

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
                                      child: ClassCardCart(
                                        classModel: classModel,
                                        courseName: courseModel?.name ?? 'Course not found',
                                        instructorName: instructorModel?.name ?? 'Instructor not found',
                                        onDelete: () {
                                          String cartItemKey = '${userId}_${item.idClass}';
                                          _removeFromCart(cartItemKey);
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          List<int> classIds = cartItems.map((item) => item.idClass).toList();
                          if (classIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Your cart is empty. Please add classes to book.')),
                            );
                          } else {
                            _bookClass(classIds, context, userId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Book All Classes',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'AfacAdflux',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<ClassModel> _getClassDetails(int classId) async {
    final snapshot = await _classRef.child(classId.toString()).get();
    final classData = Map<String, dynamic>.from(snapshot.value as Map);
    return ClassModel.fromJson(classData);
  }

  Future<CourseModel> _getCourseDetails(int courseId) async {
    final snapshot = await _courseRef.child(courseId.toString()).get();
    final courseData = Map<String, dynamic>.from(snapshot.value as Map);
    return CourseModel.fromJson(courseData);
  }

  Future<InstructorModel> _getInstructorDetails(int instructorId) async {
    final snapshot = await _instructorRef.child(instructorId.toString()).get();
    final instructorData = Map<String, dynamic>.from(snapshot.value as Map);
    return InstructorModel.fromJson(instructorData);
  }

  Future<void> _bookClass(List<int> classIds, BuildContext context, String userId) async {
    if (user == null) return;

    final bookingTime = DateTime.now().toIso8601String();

    try {
      final newBookingId = _bookingRef.push().key;
      final newBooking = BookingModel(
        bookingId: newBookingId!,
        userId: userId,
        bookingTime: bookingTime,
        classes: classIds.map((id) => id.toString()).toList(),
      );

      await _bookingRef.child(newBookingId).set(newBooking.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All classes booked successfully!')),
      );

      await _clearUserCart(userId, context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book classes: $error')),
      );
    }
  }

  Future<void> _clearUserCart(String userId, BuildContext context) async {
    final cartSnapshot = await _cartRef.once();

    if (cartSnapshot.snapshot.exists) {
      final cartItemsMap = cartSnapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var cartItemKey in cartItemsMap.keys) {
        final cartItem = cartItemsMap[cartItemKey] as Map<dynamic, dynamic>;
        if (cartItem['userId'].toString() == userId) {
          await _cartRef.child(cartItemKey).remove().then((_) {
            print("Successfully removed cart item with ID $cartItemKey for user ID $userId");
          }).catchError((error) {
            print("Failed to remove cart item with ID $cartItemKey for user ID $userId: $error");
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All cart items removed after booking.')),
      );
    } else {
      print("No cart items found in the cart root node for user ID $userId");
    }
  }
}