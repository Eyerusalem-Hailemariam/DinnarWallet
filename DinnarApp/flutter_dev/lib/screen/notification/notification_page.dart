import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../controller/notification.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController =
        Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Obx(() {
        if (notificationController.notifications.isEmpty) {
          return Center(child: Text('No notifications'));
        }

        return Column(
          children: [
            SizedBox(height: 20), // Add space between AppBar and ListView
            Expanded(
              child: ListView.builder(
                itemCount: notificationController.notifications.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(notificationController.notifications[index]),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      // Remove the notification from the list
                      String removedNotification =
                          notificationController.notifications[index];
                      notificationController.notifications.removeAt(index);

                      // Show a snackbar to indicate the notification was removed
                      Get.snackbar('Notification removed', removedNotification);
                    },
                    child: Card(
                      color: Color.fromARGB(255, 68, 255, 199),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: IconButton(
                          onPressed: () {},
                          icon: Icon(FontAwesomeIcons.bell),
                          iconSize: 20,
                        ),
                        title: Text(
                          notificationController.notifications[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
