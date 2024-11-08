import 'package:flutter/material.dart';
import '../../models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final String courseName;
  final String instructorName;

  const ClassCard({
    Key? key,
    required this.classModel,
    required this.courseName,
    required this.instructorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildClassImage(),
            const SizedBox(height: 8),
            Text(
              classModel.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'AfacAdflux',
              ),
            ),
            const SizedBox(height: 8),
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
    );
  }
  Widget _buildClassImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Image.asset(
          'assets/images/yoga_class.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image, size: 50);
          },
        ),
      ),
    );
  }
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F2D24),
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
                fontSize: 15,
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
