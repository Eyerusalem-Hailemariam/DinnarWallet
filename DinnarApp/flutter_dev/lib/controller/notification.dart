import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/constant.dart';

class NotificationController extends GetxController {
  RxList<Map<String, String>> notifications = <Map<String, String>>[].obs;

  // Function to add a notificatio

  void addNotification(String message, String category) {
    notifications.add({
      'message': message,
      'category': category,
      'timestamp': DateTime.now().toString(),
    });
  }

  Future<void> addNotifications(String message, String category) async {
    final response = await http.post(
      Uri.parse(url + 'notifications'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      print('Notification added successfully');
    } else {
      print('Failed to add notification: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchNotifications() async {
    final response = await http.get(Uri.parse(url + 'notifications'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
