import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dev/controller/notification.dart';
import 'package:get/get.dart';
import '../../controller/transactionController.dart';
import '../../controller/authentication.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../model/currency.dart';
import '../../controller/currency.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/notification_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TransactionController controller = Get.find<TransactionController>();
  final AuthenticationController authController =
      Get.find<AuthenticationController>();
  final errorMessage = ''.obs;
  List<Map<String, dynamic>> transactions = [];
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final box = GetStorage();
  List<String> notifiedCategories = [];
  final NotificationController Ncontroller = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    fetchTransactions();

    // Load notified categories from persistent storage
    final storedNotifiedCategories =
        box.read('notifiedCategories') as List<dynamic>?;

    // If any, assign them to the notifiedCategories list
    if (storedNotifiedCategories != null) {
      notifiedCategories = List<String>.from(storedNotifiedCategories);
    }

    final storedCurrencyCode = GetStorage().read('selectedCurrency');
    if (storedCurrencyCode != null) {
      currencyController.selectedCurrency.value = Currency.currencies
          .firstWhere((currency) => currency.code == storedCurrencyCode);
    }
    currencyController.selectedCurrency.listen((currency) {
      fetchTransactions();
    });
  }

  void checkSpendingLimits(double limit, double progress, String category) {
    // Check if the category has already been notified
    if (limit > 0 &&
        progress >= 1.0 &&
        !notifiedCategories.contains(category)) {
      String message = 'You have exceeded the spending limit for $category!';
      LocalNotificationService.showBasicNotification(message);
      Get.find<NotificationController>().addNotifications(message, category);

      notifiedCategories.add(category);

      box.write('notifiedCategories', notifiedCategories);
    }
  }

  String formatCurrency(double amount, Currency currency) {
    final formatter =
        NumberFormat.simpleCurrency(name: currency.code, locale: currency.code);
    return formatter.format(amount);
  }

  Future<void> fetchTransactions() async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      final response = await http.get(
        Uri.parse(url + 'transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        double totalIncome = 0.0;
        double totalExpense = 0.0;

        controller.transactions.value = data.map((transaction) {
          final Map<String, dynamic> transactionMap =
              transaction as Map<String, dynamic>;
          final category = transactionMap['category'];
          final limit = transactionMap['limit'] != null
              ? double.tryParse(transactionMap['limit'].toString()) ?? 0.0
              : null;

          final amount =
              double.tryParse(transactionMap['amount'].toString()) ?? 0.0;
          final type = transactionMap['type'];
          final transactionId = transactionMap['id']; // Fetch transaction ID

          if (type == 'Income') {
            totalIncome += amount;
          } else if (type == 'Expense') {
            totalExpense += amount;
          }

          return {
            ...transactionMap,
            'category_name': category['name'],
            'category_icon': category['icon'],
            'category_color': category['color'],
            'transaction_id': transactionId, // Add transaction ID to the data
            'limit': limit,
          };
        }).toList();

        controller.totalIncome.value = totalIncome;
        controller.totalExpense.value = totalExpense;
      } else {
        errorMessage.value =
            'Failed to fetch transactions. Please try again later.';
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'An unexpected error occurred.';
    }
  }

  void _showSetLimitBottomSheet(String category) {
    final TextEditingController limitController = TextEditingController();

    // Fetch the first expense transaction that matches the category
    final currentExpenseTransaction = controller.transactions.firstWhere(
        (t) => t['category_name'] == category && t['type'] == 'Expense',
        orElse: () =>
            {} // Return an empty map if no matching transaction is found
        );

    final currentLimit = currentExpenseTransaction.isNotEmpty
        ? currentExpenseTransaction['limit']?.toString() ?? '0.0'
        : '0.0';

    limitController.text = currentLimit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          height: MediaQuery.of(context).size.height * 0.43,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 20.0,
              bottom: keyboardHeight + 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Set Limit for $category",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 45),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Limit',
                      labelStyle:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final newLimit =
                              double.tryParse(limitController.text) ?? 0.0;

                          // Check if the current transaction is valid and is of type 'Expense'
                          if (currentExpenseTransaction.isNotEmpty &&
                              currentExpenseTransaction['type'] == 'Expense') {
                            final transactionId = currentExpenseTransaction[
                                'transaction_id']; // Use transaction ID

                            print(
                                "Attempting to update limit for transaction ID: $transactionId with limit: $newLimit");

                            if (transactionId != null &&
                                transactionId.toString().isNotEmpty) {
                              final success = await updateTransactionLimit(
                                  transactionId.toString(), newLimit);

                              // Handle success and failure
                              if (success) {
                                // Refresh the transactions after a successful update
                                await fetchTransactions();

                                // Optionally show a success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Limit updated successfully!')));
                              } else {
                                // Show an error message
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Failed to update limit. Please try again.')));
                              }
                            } else {
                              print('Invalid transactionId');
                            }
                          } else {
                            print(
                                'Cannot set limit for non-expense transaction or no transaction found');
                          }

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 68, 255, 199),
                        ),
                        child: Text(
                          'Set',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> updateCategoryLimit(String categoryId, double limit) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      final response = await http.put(
        Uri.parse(url + 'transactions/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'limit': limit,
          'type': 'Expense', // Ensure type is explicitly set
        }),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to update limit: ${response.body}");
        return false;
      }
    } catch (error) {
      print("Error occurred while updating limit: $error");
      return false;
    }
  }

  Future<bool> updateTransactionLimit(
      String transactionId, double limit) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      final response = await http.put(
        Uri.parse(url +
            'transactions/$transactionId'), // Use transaction ID in the URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'limit': limit,
          'type': 'Expense', // Ensure type is explicitly set
        }),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to update limit: ${response.body}");
        return false;
      }
    } catch (error) {
      print("Error occurred while updating limit: $error");
      return false;
    }
  }

  Map<String, Map<String, dynamic>> get _groupedExpenseTransactions {
    final Map<String, Map<String, dynamic>> groupedTransactions = {};

    for (var transaction in controller.transactions) {
      if (transaction['type'] == 'Expense') {
        final category = transaction['category_name'] ?? 'Unknown';
        final amount = double.tryParse(transaction['amount'].toString()) ?? 0.0;
        final limit = double.tryParse(transaction['limit'].toString()) ?? 0.0;

        if (groupedTransactions.containsKey(category)) {
          groupedTransactions[category]!['amount'] += amount;
        } else {
          groupedTransactions[category] = {
            'amount': amount,
            'limit': limit,
          };
        }

        // Call checkSpendingLimits for each category transaction
        final progress = limit > 0 ? amount / limit : 0.0;
        checkSpendingLimits(limit, progress, category);
      }
    }

    return groupedTransactions;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.9;
    final containerHeight = screenHeight * 0.3;
    final paddingHorizontal = screenWidth * 0.06;
    final paddingVertical = screenHeight * 0.03;
    final iconSize = screenWidth * 0.07;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7FFE6),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: paddingVertical,
                      horizontal: paddingHorizontal,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Balance".tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF130F39),
                          ),
                        ),
                        Obx(() {
                          final currencySymbol =
                              currencyController.selectedCurrency.value.symbol;
                          final totalIncome = controller.transactions.fold(
                            0.0,
                            (sum, transaction) {
                              if (transaction['type'] == 'Income') {
                                final amount = double.tryParse(
                                        transaction['amount'].toString()) ??
                                    0.0;
                                return sum + amount;
                              }
                              return sum;
                            },
                          );

                          final totalExpense = controller.transactions.fold(
                            0.0,
                            (sum, transaction) {
                              if (transaction['type'] == 'Expense') {
                                final amount = double.tryParse(
                                        transaction['amount'].toString()) ??
                                    0.0;
                                return sum + amount;
                              }
                              return sum;
                            },
                          );

                          final totalAmount = totalIncome - totalExpense;

                          return Text(
                            ' $currencySymbol${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF130F39),
                            ),
                          );
                        }),
                        SizedBox(height: screenHeight * 0.052),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: iconSize,
                                      height: iconSize,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34D13A),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          CupertinoIcons.arrow_down,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      "Income".tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF156157),
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() {
                                  final currencySymbol = currencyController
                                      .selectedCurrency.value.symbol;
                                  return Text(
                                    " $currencySymbol${controller.totalIncome.value.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: const Color(0xFF130F39),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: iconSize,
                                      height: iconSize,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFA00505),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          CupertinoIcons.arrow_up,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      "Expense".tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFF4D00),
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(() {
                                  final currencySymbol = currencyController
                                      .selectedCurrency.value.symbol;
                                  return Text(
                                    "$currencySymbol${controller.totalExpense.value.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: const Color(0xFF130F39),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Spending Limit".tr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),
                ),
                Obx(() {
                  final currencySymbol =
                      currencyController.selectedCurrency.value.symbol;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: _groupedExpenseTransactions.keys.length,
                      itemBuilder: (context, index) {
                        final category =
                            _groupedExpenseTransactions.keys.toList()[index];
                        final transaction =
                            _groupedExpenseTransactions[category]!;
                        final amount = transaction['amount'] as double;
                        final limit = transaction['limit'] as double;
                        final progress = limit > 0 ? amount / limit : 0.0;

                        return GestureDetector(
                          onTap: () {
                            _showSetLimitBottomSheet(category);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: isDark ? Colors.black : Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 215, 120, 231),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(category),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    LinearProgressIndicator(
                                      value: limit > 0
                                          ? progress.clamp(0.0, 1.0)
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        limit > 0
                                            ? (progress >= 1.0
                                                ? Colors.red
                                                : Colors.green)
                                            : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      limit > 0
                                          ? 'Amount Spent: $currencySymbol${amount.toStringAsFixed(2)} / Limit: $currencySymbol${limit.toStringAsFixed(2)}'
                                          : 'Set Limit',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
