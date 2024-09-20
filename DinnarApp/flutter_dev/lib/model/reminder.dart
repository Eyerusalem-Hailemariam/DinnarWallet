class Reminder {
  int id;
  String title;
  String descripition;
  DateTime dateTime;
  String category; // 'Income' or 'Expense'
  String repeatOption;

  Reminder({
    required this.id,
    required this.title,
    required this.descripition,
    required this.dateTime,
    required this.category,
    required this.repeatOption,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      descripition: json['descripition'] ?? '',
      dateTime: json['date_time'] != null ? DateTime.parse(json['date_time']) : DateTime.now(),
      category: json['category'] ?? 'Unknown',
      repeatOption: json['repeat_option'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descripition': descripition,
      'date_time': dateTime.toIso8601String(),
      'category': category,
      'repeat_option': repeatOption,
    };
  }
}
