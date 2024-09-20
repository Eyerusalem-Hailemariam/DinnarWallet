import 'package:get/get.dart';
import '../model/reminder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/constant.dart';

class ReminderController extends GetxController {
  var reminders = <Reminder>[].obs;

  @override
  void onInit() {
    fetchReminders();
    super.onInit();
  }

// Flutter: ReminderController.dart

Future<void> updateReminder(Reminder reminder) async {
  try {
    final response = await http.put(
      Uri.parse(url + 'reminders/${reminder.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reminder.toJson()),
    );

    if (response.statusCode == 200) {
      int index = reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        reminders[index] = reminder;  // Update the reminder in the list
      }
      // Print to check if the UI updates
      print('Reminder updated successfully');
    } else {
      throw Exception('Failed to update reminder');
    }
  } catch (e) {
    print('Error updating reminder: $e');
    throw Exception('Failed to update reminder');
  }
}


  Future<void> fetchReminders() async {
    try {
      final response = await http.get(Uri.parse(url + 'reminders'));

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
        throw Exception('Failed to load reminders');
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      throw Exception('Failed to fetch reminders');
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    final response = await http.post(
      Uri.parse(url + 'reminders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reminder.toJson()),
    );

    if (response.statusCode == 201) {
      reminders.add(reminder);
    } else {
      throw Exception('Failed to add reminder');
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    try {
      final response = await http.delete(
        Uri.parse(url + 'reminders/${reminder.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
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
