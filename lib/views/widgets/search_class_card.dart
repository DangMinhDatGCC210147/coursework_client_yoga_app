import 'package:flutter/material.dart';
import 'package:yoga_client/themes/app_colors.dart';
import '../../models/class_model.dart';

class SearchClassCard extends StatelessWidget {
  final ClassModel classModel;
  final String courseName;
  final String instructorName;

  const SearchClassCard({
    Key? key,
    required this.classModel,
    required this.courseName,
    required this.instructorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Card(
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 90),
                    Text(
                      classModel.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'AfacAdflux',
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInfoRow(Icons.calendar_today, classModel.date),
                    _buildInfoRow(Icons.book, courseName),
                    _buildInfoRow(Icons.person, instructorName),
                    _buildInfoRow(Icons.comment, classModel.comments?.isNotEmpty == true ? classModel.comments! : "No comments"),
                  ],
                ),
              ),
            ],
          ),
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

  // Function to create information row with icon
  Widget _buildInfoRow(IconData icon, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.backgroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
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