import 'package:flutter/material.dart';
import '../../models/class_model.dart';

class ClassCardCart extends StatelessWidget {
  final ClassModel classModel;
  final String courseName;
  final String instructorName;
  final VoidCallback onDelete;

  const ClassCardCart({
    Key? key,
    required this.classModel,
    required this.courseName,
    required this.instructorName,
    required this.onDelete,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            _buildClassImage(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 30, color: Colors.white),
                      onPressed: onDelete,
                      tooltip: 'Remove from cart',
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    classModel.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'AfacAdflux',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow("Date:", classModel.date),
                  _buildInfoRow("Course:", courseName),
                  _buildInfoRow("Instructor:", instructorName),
                  _buildInfoRow(
                    "Comments:",
                    classModel.comments?.isNotEmpty == true
                        ? classModel.comments!
                        : "No comments",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create class image
  Widget _buildClassImage() {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Image.asset(
        'assets/images/yoga_class.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image, size: 50);
        },
      ),
    );
  }

  // Function to create information row
  Widget _buildInfoRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontFamily: 'AfacAdflux',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 7,
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'AfacAdflux',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}