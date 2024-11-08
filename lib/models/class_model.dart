class ClassModel {
  final int id;
  final String name;
  final String date;
  final int courseId;
  final int instructor;
  final String? comments;

  ClassModel({
    required this.id,
    required this.name,
    required this.date,
    required this.courseId,
    required this.instructor,
    this.comments,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String,
      date: json['date'].toString(),
      courseId: int.tryParse(json['courseId'].toString()) ?? 0,
      instructor: int.tryParse(json['instructor'].toString()) ?? 0,
      comments: json['comments']?.toString(),
    );
  }
}