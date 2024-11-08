class InstructorModel {
  String id;
  String name;
  String email;
  int roleId;

  InstructorModel({
    required this.id,
    required this.name,
    required this.email,
    this.roleId = 3,
  });

  // Convert InstructorModel to Map to save to Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roleId': roleId,
    };
  }

  // Convert Map from Firebase to InstructorModel
  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      roleId: int.tryParse(json['roleId'].toString()) ?? 3,
    );
  }
}
