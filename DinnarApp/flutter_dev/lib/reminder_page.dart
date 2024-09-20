import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'model/reminder.dart';
import 'constant/constant.dart';
import 'controller/reminder.dart';

class ReminderPage extends StatefulWidget {
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  late ReminderController reminderController;
  String selectedFilter = 'All'; // Track the selected filter

  @override
  void initState() {
    super.initState();
    reminderController = Get.put(ReminderController());
    reminderController.fetchReminders();
  }

  List<Reminder> get filteredReminders {
    // Apply filtering based on title and selected filter
    return reminderController.reminders.where((reminder) {
      final matchesTitle =
          reminder.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedFilter == 'All' ||
          (selectedFilter == 'Income' && reminder.category == 'Income') ||
          (selectedFilter == 'Expense' && reminder.category == 'Expense');
      return matchesTitle && matchesCategory;
    }).toList();
  }

  String searchQuery = ''; // Variable to hold the search query

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddReminderDialog(context, reminderController);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                setState(() {
                  selectedFilter = result; // Update selected filter
                });
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(value: 'All', child: Text('All')),
                PopupMenuItem<String>(value: 'Income', child: Text('Income')),
                PopupMenuItem<String>(value: 'Expense', child: Text('Expense')),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update search query
                });
              },
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
                hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              style: TextStyle(
                  color:
                      isDarkMode ? Colors.white : Colors.black), // Text color
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (reminderController.reminders.isEmpty) {
          return Center(
            child: Text(
              'No reminders yet!',
              style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.grey),
            ),
          );
        }

        final remindersToShow = filteredReminders; // Get the filtered reminders

        return ListView.builder(
          itemCount: remindersToShow.length,
          itemBuilder: (context, index) {
            final reminder = remindersToShow[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: const Color.fromARGB(255, 68, 255, 199),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(
                    reminder.category == 'Income'
                        ? Icons.attach_money
                        : Icons.money_off,
                    color: isDarkMode ? Colors.black : null,
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.black : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    '${reminder.descripition}\nDue: ${reminder.dateTime.toLocal()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.black : Colors.black54,
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    _showEditReminderDialog(
                        context, reminderController, reminder);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: isDarkMode ? Colors.black : null),
                        onPressed: () {
                          _showEditReminderDialog(
                              context, reminderController, reminder);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () async {
                          // Confirm deletion
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Reminder',
                                    style: TextStyle(
                                        color:
                                            isDarkMode ? Colors.white : null)),
                                content: Text(
                                    'Are you sure you want to delete this reminder?',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : null)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('Delete',
                                        style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white
                                                : null)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete) {
                            try {
                              await reminderController.deleteReminder(reminder);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to delete reminder')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddReminderDialog(
      BuildContext context, ReminderController reminderController) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String category = 'Expense';
    String repeatOption = 'None';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Reminder',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text("Date and Time"),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: category,
                      items: <String>['Income', 'Expense']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: repeatOption,
                      items: <String>['None', 'Daily', 'Weekly', 'Monthly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          repeatOption = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final reminder = Reminder(
                              id: DateTime.now().millisecondsSinceEpoch,
                              title: titleController.text,
                              descripition: descriptionController.text,
                              dateTime: selectedDate,
                              category: category,
                              repeatOption: repeatOption,
                            );

                            try {
                              await reminderController.addReminder(reminder);
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to add reminder')),
                              );
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditReminderDialog(BuildContext context,
      ReminderController reminderController, Reminder reminder) {
    final titleController = TextEditingController(text: reminder.title);
    final descriptionController =
        TextEditingController(text: reminder.descripition);
    DateTime selectedDate = reminder.dateTime;
    String category = reminder.category;
    String repeatOption = reminder.repeatOption ?? 'None';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Reminder',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text("Date and Time"),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: category,
                      items: <String>['Income', 'Expense']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: repeatOption,
                      items: <String>['None', 'Daily', 'Weekly', 'Monthly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          repeatOption = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final updatedReminder = Reminder(
                              id: reminder.id,
                              title: titleController.text,
                              descripition: descriptionController.text,
                              dateTime: selectedDate,
                              category: category,
                              repeatOption: repeatOption,
                            );

                            try {
                              await reminderController
                                  .updateReminder(updatedReminder);
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to update reminder')),
                              );
                            }
                          },
                          child: Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
