import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dev/model/currency.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'constant/constant.dart';
import 'controller/authentication.dart';
import 'transactionController.dart';
import 'package:flutter/cupertino.dart';
import 'zoomed_transaction.dart';
import 'controller/currency.dart';
import 'package:get_storage/get_storage.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final AuthenticationController authController =
      Get.find<AuthenticationController>();
  final errorMessage = ''.obs;
  final TransactionController controller = Get.find<TransactionController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  Currency? selectedCurrency;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();

    final storedCurrencyCode = GetStorage().read('selectedCurrency');
    if (storedCurrencyCode != null) {
      currencyController.selectedCurrency.value = Currency.currencies
          .firstWhere((currency) => currency.code == storedCurrencyCode);
    }

    currencyController.selectedCurrency.listen((currency) {
      fetchTransactions();
    });
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        double totalIncome = 0.0;
        double totalExpense = 0.0;

        // Ensure existing transactions are not overwritten
        final List<Map<String, dynamic>> transactions = data.map((transaction) {
          final Map<String, dynamic> transactionMap =
              transaction as Map<String, dynamic>;
          final category = transactionMap['category'];
          final amount =
              double.tryParse(transactionMap['amount'].toString()) ?? 0.0;
          final type = transactionMap['type'];

          // Convert the amount based on the selected currency's exchange rate

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
            // Store the converted amount
          };
        }).toList();

        // Update the controller with the new data and totals
        controller.setTransactions(transactions);
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

  Future<void> deleteTransaction(String transactionId, int index) async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      final response = await http.delete(
        Uri.parse(url + 'transactions/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Fetch updated transactions to ensure the state is accurate
        await fetchTransactions();
      } else {
        // Handle server error
        print('Failed to delete transaction.');
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                      final totalAmount = controller.totalIncome.value -
                          controller.totalExpense.value;
                      final currencySymbol =
                          currencyController.selectedCurrency.value.symbol;
                      return Text(
                        '$currencySymbol${totalAmount.toStringAsFixed(2)}',
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
                                "$currencySymbol${controller.totalIncome.value.toStringAsFixed(2)}",
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
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.03,
                horizontal: screenWidth * 0.03,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transactions history".tr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF222222),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ZoomedTransactionPage(
                              transactions: controller.transactions)));
                    },
                    child: Text(
                      "See all".tr,
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.5, // Adjust height based on screen
              child: Obx(() {
                final transactions = controller.transactions;
                final currencySymbol =
                    currencyController.selectedCurrency.value.symbol;

                if (transactions.isEmpty) {
                  return Center(child: Text('No transactions available.'));
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final transactionId = transaction['id'];
                    final categoryName =
                        transaction['category_name'] ?? 'Unknown Category';
                    final transactionDate =
                        transaction['transaction_date'] ?? 'Unknown Date';
                    final amount = transaction['amount'] != null
                        ? double.tryParse(transaction['amount'].toString()) ??
                            0.0
                        : 0.0;
                    final categoryColor = transaction['category_color'] != null
                        ? colorFromHex(transaction['category_color'])
                        : Colors.grey;
                    final categoryIcon =
                        transaction['category_icon'] ?? 'default_icon';
                    final isIncome = transaction['type'] == 'Income';

                    return Dismissible(
                      key: ValueKey(transactionId.toString()),
                      background: Container(
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // Handle the dismissal
                        deleteTransaction(transactionId.toString(), index);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: categoryColor,
                          child: Image.asset(
                            'assets/images/${categoryIcon}.png',
                            width: iconSize,
                            height: screenWidth * 0.05,
                          ),
                        ),
                        title: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF222222),
                          ),
                        ),
                        subtitle: Text(
                          transactionDate,
                          style: TextStyle(
                            fontSize: screenWidth * 0.027,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF666666),
                          ),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}$currencySymbol${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            color: isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
