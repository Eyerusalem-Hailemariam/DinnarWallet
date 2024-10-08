class NotificationModel {
  final String message;
  final String category;
  final DateTime dateTime;

  NotificationModel({
    required this.message,
    required this.category,
    required this.dateTime,
  });

 
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['data']['message'],
      category: json['data']['category'],
      dateTime: DateTime.parse(json['created_at']),
    );
  }
}
