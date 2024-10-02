class NotificationModel {
  final String title;
  final String message;
  final DateTime dateTime;
  // To check if the expense limit is reached

  NotificationModel({
    required this.title,
    required this.message,
    required this.dateTime,
  });
}
