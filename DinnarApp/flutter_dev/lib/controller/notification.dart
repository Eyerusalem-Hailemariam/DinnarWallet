import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = <String>[].obs;

  // Method to add a notification only if it doesn't already exist
  void addNotification(String message) {
    if (!notifications.contains(message)) {
      notifications.add(message);
    }
  }
}
