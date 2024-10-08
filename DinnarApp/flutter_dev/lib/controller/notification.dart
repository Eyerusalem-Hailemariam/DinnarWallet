import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/constant.dart';

class NotificationController extends GetxController {
  // List to store notifications
  RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  // Method to add a notification
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

    if (response.statusCode == 201) {
      print('Notification added successfully');
      fetchNotifications(); // Fetch updated notifications after adding
    } else {
      print('Failed to add notification: ${response.body}');
    }
  }

  Future<void> fetchNotifications() async {
    print('Fetching notifications...');

    final response = await http.get(Uri.parse(url + 'notifications'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the response as a list of dynamic objects
      List<dynamic> notificationsList = jsonDecode(response.body);

      // Map the notifications and handle null values
      notifications.value = notificationsList.map((notification) {
        return {
          'message': notification['message'] ?? 'No message',
          'category': notification['category'] ?? 'Uncategorized',
          'timestamp': notification['timestamp'] ?? 'Unknown date',
        };
      }).toList();

      print('Notifications fetched successfully: $notifications');
    } else {
      print('Failed to load notifications: ${response.body}');
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await http.delete(
      Uri.parse(url + 'notifications/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Notification deleted successfully');
      notifications.removeWhere((notification) => notification['id'] == id);
    } else {
      print('Failed to delete notification : ${response.body}');
    }
  }
}
