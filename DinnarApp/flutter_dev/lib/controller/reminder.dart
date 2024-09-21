import 'package:get/get.dart';
import '../model/reminder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/constant.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class ReminderController extends GetxController {
  var reminders = <Reminder>[].obs;
  final box = GetStorage();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchReminders();
    super.onInit();
  }

// Flutter: ReminderController.dart
  Future<void> scheduleNotification(Reminder reminder) async {
    final DateTime now = DateTime.now();
    final Duration difference = reminder.dateTime.difference(now);

    // If the reminder time is in the past, skip scheduling
    if (difference.isNegative) {
      errorMessage.value =
          'Reminder time is in the past. Please select a future time.';
      print('Reminder time is in the past. Skipping notification.');
      return;
    }

    Timer(difference, () async {
      await _sendNotification(reminder);

      // Check the repeat option and schedule the next notification
      if (reminder.repeatOption == 'Daily') {
        // Schedule for the next day
        DateTime nextReminderTime = reminder.dateTime.add(Duration(days: 1));
        reminder.dateTime = nextReminderTime; // Update reminder with new time
        print(
            'Setting next reminder for "${reminder.title}" to ${nextReminderTime.toIso8601String()} (Daily)');
        await scheduleNotification(reminder); // Re-schedule the notification
      } else if (reminder.repeatOption == 'Weekly') {
        // Schedule for the next week
        DateTime nextReminderTime = reminder.dateTime.add(Duration(days: 7));
        reminder.dateTime = nextReminderTime; // Update reminder with new time
        print(
            'Setting next reminder for "${reminder.title}" to ${nextReminderTime.toIso8601String()} (Weekly)');
        await scheduleNotification(reminder); // Re-schedule the notification
      } else if (reminder.repeatOption == 'Monthly') {
        // Schedule for the next month
        DateTime nextReminderTime = DateTime(
          reminder.dateTime.year,
          reminder.dateTime.month + 1,
          reminder.dateTime.day,
          reminder.dateTime.hour,
          reminder.dateTime.minute,
        );
        reminder.dateTime = nextReminderTime; // Update reminder with new time
        print(
            'Setting next reminder for "${reminder.title}" to ${nextReminderTime.toIso8601String()} (Monthly)');
        await scheduleNotification(reminder); // Re-schedule the notification
      }
    });

    print(
        'Notification scheduled for "${reminder.title}" in $difference seconds.');
  }

  Future<void> _sendNotification(Reminder reminder) async {
    final token = box.read('token');
    final response = await http.post(
      Uri.parse(url + 'send-notification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include the token
      },
      body: jsonEncode({
        'title': reminder.title,
        'description': reminder.descripition,
        'date_time': reminder.dateTime.toIso8601String(),
      }),
    );

    print('API Response: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    final token = box.read('token');
    try {
      final response = await http.put(
        Uri.parse(url + 'reminders/${reminder.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reminder.toJson()),
      );

      if (response.statusCode == 200) {
        int index = reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          reminders[index] = reminder; // Update the reminder in the list
        }
        // Print to check if the UI updates
        print('Reminder updated successfully');
        await scheduleNotification(reminder);
      } else {
        throw Exception('Failed to update reminder');
      }
    } catch (e) {
      print('Error updating reminder: $e');
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    final token = box.read('token');
    final response = await http.post(
      Uri.parse(url + 'reminders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reminder.toJson()),
    );
    print(
        'Adding reminder: ${reminder.title}, Repeat Option: ${reminder.repeatOption}');

    if (response.statusCode == 201) {
      reminders.add(reminder);
      print('Reminder added successfully');

      // Schedule the notification after adding the reminder
      await scheduleNotification(reminder);
    } else {
      print('Failed to add reminder: ${response.body}');
      throw Exception('Failed to add reminder');
    }
  }

  Future<void> fetchReminders() async {
    final token = box.read('token'); // Read the token from storage
    try {
      final response = await http.get(
        Uri.parse(url + 'reminders'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Include the token here
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List remindersJson = json.decode(response.body);

        // Convert JSON list to list of Reminder objects
        List<Reminder> parsedReminders = remindersJson
            .map((json) {
              try {
                return Reminder.fromJson(json);
              } catch (e) {
                print('Error parsing JSON: $e');
                return null; // Handle the error but continue
              }
            })
            .whereType<Reminder>()
            .toList(); // Filter out null values

        reminders.value = parsedReminders;
      } else {
        print('Error: ${response.body}'); // Print error response
        throw Exception('Failed to load reminders');
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      throw Exception('Failed to fetch reminders');
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      final token = box.read('token');
      final response = await http.delete(
        Uri.parse(url + 'reminders/${reminder.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Successfully deleted the reminder from the database
        reminders.remove(reminder); // Remove the reminder from the UI list
      } else {
        throw Exception('Failed to delete reminder');
      }
    } catch (e) {
      print('Error deleting reminder: $e');
      throw Exception('Failed to delete reminder');
    }
  }
}
