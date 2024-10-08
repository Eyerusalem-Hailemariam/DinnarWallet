import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/notification.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController =
        Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Obx(() {
        if (notificationController.notifications.isEmpty) {
          return Center(child: Text('No notifications'));
        }

        return ListView.builder(
          itemCount: notificationController.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationController.notifications[index];
            return Container(
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 68, 255, 199),
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(CupertinoIcons.bell_solid),
                title: Text(notification['message'] ?? ''),
                subtitle: Text(
                  'Time: ${notification['timestamp'] ?? ''}',
                ),
                trailing: IconButton(
                    onPressed: () async {
                      await notificationController
                          .deleteNotification(notification['id']);
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    )),
              ),
            );
          },
        );
      }),
    );
  }
}
