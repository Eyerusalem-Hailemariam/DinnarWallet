import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTransactionUpdate;

  const NotificationPage({super.key, required this.onTransactionUpdate});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedTab = 0;
  String _searchQuery = '';

  void _toggleTheme(int selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
    });
  }

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Car Rental Payment',
      'description': 'Your car rental payment is due.',
      'transactionData': {
        'category': 'Car Rental',
        'amount': 100.0,
        'type': 'Expense',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'icon': 'car',
        'color': Colors.blue, // This is a Color
      },
      'isRead': false,
    },
    {
      'title': 'Car Rental Payment',
      'description': 'Your car rental payment is due.',
      'transactionData': {
        'category': 'Car Rental',
        'amount': 100.0,
        'type': 'Income',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'icon': 'car',
        'color': Colors.blue, // This is a Color
      },
      'isRead': false,
    },
    {
      'title': 'Rental Payment',
      'description': 'Your car rental payment is due.',
      'transactionData': {
        'category': ' Rental',
        'amount': 100.0,
        'type': 'Income',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'icon': 'car',
        'color': Colors.amber, // This is a Color
      },
      'isRead': true,
    },
    // Add more notifications here...
  ];

  List<Map<String, dynamic>> _filteredNotifications() {
    return _notifications.where((notification) {
      String type = notification['transactionData']['type'];
      String title = notification['title'].toLowerCase();
      return ((type == 'Income' && _selectedTab == 0) ||
              (type == 'Expense' && _selectedTab == 1)) &&
          title.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleNotificationTap(Map<String, dynamic> transactionData) {
    widget.onTransactionUpdate(
        transactionData); // This should add the transaction
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction Added: ${transactionData['category']}'),
      ),
    );
  }

  void _toggleReadStatus(int index) {
    setState(() {
      _notifications[index]['isRead'] = !_notifications[index]['isRead'];
    });
  }

  void _removeNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7FFE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC7FFE5),
        actions: const [
          Icon(
            Icons.notification_add,
            color: Colors.black,
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotifications().length,
              itemBuilder: (context, index) {
                final notification = _filteredNotifications()[index];
                bool isRead = notification['isRead'];

                final Color? iconColor =
                    notification['transactionData']['color'] is Color
                        ? notification['transactionData']['color'] as Color
                        : null;

                return Dismissible(
                  key: Key(notification['title'] +
                      index.toString()), // Unique key for each item
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeWhere(
                          (item) => item['title'] == notification['title']);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification dismissed'),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _handleNotificationTap(notification['transactionData']);
                      },
                      onLongPress: () {
                        _toggleReadStatus(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: isRead
                              ? Colors.black
                              : const Color.fromARGB(255, 73, 66, 66),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: iconColor ?? Colors.grey,
                          ),
                          title: Text(
                            notification['title'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            notification['description'],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
