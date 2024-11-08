class UserModel {
  String id;
  String name;
  String email;
  int roleId;
  String password;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.roleId = 2,
  });

  // Convert UserModel to Map to save to Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roleId': roleId,
      'password': password,
    };
  }

  // Convert Map from Firebase to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      roleId: json['roleId'] ?? 2,
    );
  }
}