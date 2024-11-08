class CourseModel {
  int courseId;
  String name;
  String type;
  String price;
  String duration;
  int capacity;
  String description;
  String courseDay;
  String courseTime;

  CourseModel({
    required this.courseId,
    required this.name,
    required this.type,
    required this.price,
    required this.duration,
    required this.capacity,
    required this.description,
    required this.courseDay,
    required this.courseTime,
  });

  // Convert Map from Firebase to CourseModel
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: int.tryParse(json['courseId'].toString()) ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? '',
      duration: json['duration'] ?? '',
      capacity: int.tryParse(json['capacity'].toString()) ?? 0,
      description: json['description'] ?? '',
      courseDay: json['courseDay'] ?? '',
      courseTime: json['courseTime'] ?? '',
    );
  }

  // Convert CourseModel to Map to save to Firebase
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'name': name,
      'type': type,
      'price': price,
      'duration': duration,
      'capacity': capacity,
      'description': description,
      'courseDay': courseDay,
      'courseTime': courseTime,
    };
  }
}