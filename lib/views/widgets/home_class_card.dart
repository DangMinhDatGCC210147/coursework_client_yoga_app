import 'package:flutter/material.dart';
import '../../models/class_model.dart';

class HomeClassCard extends StatelessWidget {
  final ClassModel classModel;
  final String courseName;
  final String instructorName;

  const HomeClassCard({
    Key? key, required this.classModel,
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/yoga_class.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tên lớp học
            Text(
              classModel.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                  fontFamily: 'AfacAdflux'
              ),
            ),
            const SizedBox(height: 8),

            // Các thông tin chi tiết của lớp học
            _buildInfoRow("Date:", classModel.date, alignment: MainAxisAlignment.end), // Căn phải cho nội dung
            _buildInfoRow("Course:", courseName.toString(), alignment: MainAxisAlignment.end),
            _buildInfoRow("Instructor:", instructorName.toString(), alignment: MainAxisAlignment.end),
            _buildInfoRow(
              "Comments:",
              classModel.comments != null && classModel.comments!.isNotEmpty
                  ? classModel.comments!
                  : "No comments",
              alignment: MainAxisAlignment.end,
            )
      ],
        ),
      ),
    );
  }

  // Hàm tạo hàng thông tin với tùy chọn căn chỉnh
  Widget _buildInfoRow(String title, String content, {MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F2D24),
                fontFamily: 'AfacAdflux'
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 7,
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: 'AfacAdflux',
              fontSize: 15,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}