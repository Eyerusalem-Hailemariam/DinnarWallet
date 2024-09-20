import 'package:flutter/material.dart';
import 'package:flutter_dev/controller/authentication.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constant/constant.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

List<Map<String, dynamic>>? _cachedCategories;

Future<List<Map<String, dynamic>>> fetchCategories(
    {bool excludeLinked = false}) async {
  // Check if we have cached categories and if they are valid
  if (_cachedCategories != null && !excludeLinked) {
    return _cachedCategories!;
  }

  final box = GetStorage();
  final token = box.read('token');

  final response = await http.get(
    Uri.parse(url + 'categories'), // Fetch all categories
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);

    Set<String> seenCategoryNames = {};
    List<Map<String, dynamic>> categories = [];

    for (var category in jsonData) {
      String name = category['name'] ?? '';
      if (!seenCategoryNames.contains(name)) {
        seenCategoryNames.add(name);
        categories.add({
          'name': name,
          'icon': category['icon'] ?? '',
          'color': Color(int.parse(
                  category['color']?.replaceFirst('#', '') ?? 'FFFFFF',
                  radix: 16) +
              0xFF000000),
          'linked': category['linked'] ?? false,
        });
      }
    }

    if (excludeLinked) {
      categories = categories
          .where((category) => !(category['linked'] as bool))
          .toList();
    }

    _cachedCategories = categories;
    return _cachedCategories!;
  } else {
    throw Exception('Failed to load categories');
  }
}

String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

void showAddTransactionDialog(
  BuildContext context,
  int selectedTab,
  String? selectedCategory,
  TextEditingController dateController,
  TextEditingController amountController,
  Function(Map<String, dynamic>) addTransaction,
  bool isDarkMode,
) {
  final AuthenticationController authController =
      Get.find<AuthenticationController>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 54, 50, 50)
            : const Color(0xFFF4F6F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 17),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Income and Expense Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : const Color(0xFFF4F6F6),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: isDarkMode
                                    ? const Color.fromARGB(255, 134, 128, 128)
                                    : const Color.fromARGB(255, 223, 211, 211)),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                // Income Tab
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 0;
                                    });
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: selectedTab == 0
                                                ? (isDarkMode
                                                    ? Colors.grey[700]
                                                    : Colors.white)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: selectedTab == 0
                                                  ? const Color.fromARGB(
                                                      255, 219, 211, 211)
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Income",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                                // Expense Tab
                                Expanded(
                                    child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 1;
                                    });
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: selectedTab == 1
                                                ? (isDarkMode
                                                    ? Colors.grey[700]
                                                    : Colors.white)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: selectedTab == 1
                                                  ? const Color.fromARGB(
                                                      255, 219, 211, 211)
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Expense",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ))
                              ]),
                        ),
                        const SizedBox(height: 8),
                        // Category Selection
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchCategories(excludeLinked: true),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text('No categories available');
                            } else {
                              List<Map<String, dynamic>> categories =
                                  snapshot.data!;
                              return Container(
                                width: double.infinity,
                                height: 49,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 54, 50, 50)
                                      : const Color(0xFFF4F6F6),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? const Color.fromARGB(
                                            255, 134, 128, 128)
                                        : const Color.fromARGB(255, 41, 39, 39),
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? const Color.fromARGB(255, 54, 50, 50)
                                        : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  value: selectedCategory,
                                  items: categories.map((categoryData) {
                                    return DropdownMenuItem<String>(
                                      value: categoryData['name'],
                                      child: Row(
                                        children: [
                                          if (categoryData['icon'] != null &&
                                              categoryData['color'] != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                color: categoryData['color'],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/images/${categoryData['icon']}.png',
                                                height: 24,
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          Text(categoryData['name']),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                  icon: const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Icon(Icons.arrow_drop_down),
                                  ),
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  dropdownColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                ),
                              );
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isDarkMode
                                      ? const Color.fromARGB(255, 134, 128, 128)
                                      : const Color.fromARGB(255, 41, 39, 39)),
                            ),
                            child: TextField(
                              controller: dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                hintText: 'Select Date',
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    dateController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Amount",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: amountController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: "Enter amount",
                              hintStyle: TextStyle(
                                color:
                                    isDarkMode ? Colors.grey : Colors.black54,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            double? transactionAmount =
                                double.tryParse(amountController.text);
                            if (transactionAmount == null ||
                                transactionAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid amount.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Ensure a category is selected
                            if (selectedCategory == null ||
                                selectedCategory!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a category.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Fetch categories again to get the latest data
                            final categories = await fetchCategories();

                            // Get the selected category data
                            final selectedCategoryData = categories.firstWhere(
                              (category) =>
                                  category['name'] == selectedCategory,
                              orElse: () => null!,
                            );

                            if (selectedCategoryData == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selected category not found.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Convert date from dd/MM/yyyy to YYYY-MM-DD
                            final dateFormatInput = DateFormat('dd/MM/yyyy');
                            final dateFormatOutput = DateFormat('yyyy-MM-dd');
                            final date =
                                dateFormatInput.parse(dateController.text);
                            final formattedDate = dateFormatOutput.format(date);

                            // Call the function to add the new category and transaction
                            await authController.addNewCategoryAndTransaction(
                              context: context,
                              categoryName: selectedCategoryData['name'],
                              categoryIcon: selectedCategoryData['icon'],
                              categoryColor:
                                  colorToHex(selectedCategoryData['color']),
                              transactionAmount: transactionAmount,
                              selectedDate: formattedDate,
                              transactionType:
                                  selectedTab == 0 ? 'Income' : 'Expense',
                            );

                            // Prepare transaction data to pass to the addTransaction function
                            final transactionData = {
                              'category_name': selectedCategoryData['name'],
                              'category_icon': selectedCategoryData['icon'],
                              'category_color':
                                  colorToHex(selectedCategoryData['color']),
                              'amount': transactionAmount,
                              'transaction_date': formattedDate,
                              'type': selectedTab == 0 ? 'Income' : 'Expense',
                            };

                            // Add the transaction to the list
                            addTransaction(transactionData);
                            print(transactionData);
                            // Close the dialog after the transaction is added
                            Navigator.of(context).pop();
                          } catch (e) {
                            print('Error adding transaction: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding transaction: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF130F39),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
