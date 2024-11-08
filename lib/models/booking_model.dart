class BookingModel {
  final String bookingId;
  final String userId;
  final String bookingTime;
  final List<String> classes;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.bookingTime,
    required this.classes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      bookingTime: json['bookingTime'] as String,
      classes: (json['classes'] as List<dynamic>).map((item) => item.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'bookingTime': bookingTime,
      'classes': classes,
    };
  }
}