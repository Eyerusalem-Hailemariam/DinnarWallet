import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_dev/controller/currency.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/category_card.dart';
import '../../constant/constant.dart';
import 'package:intl/intl.dart';
import '../../model/totalchart.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
  int _selectedTab = 0; // Income = 0, Expense = 1
  String _selectedPeriod = 'Monthly'; // Default selected period
  List<Map<String, dynamic>> transactions = [];
  final errorMessage = ''.obs; // Observable error message
  final CurrencyController currencyController =
      Get.find<CurrencyController>(); // GetX controller for currency
  var filteredTransactions =
      <Map<String, dynamic>>[].obs; // Observable list for filtered transactions
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final box = GetStorage();
      final token = box.read('token');
      print('Fetching transactions with token: $token'); // Debug statement

      final response = await http.get(
        Uri.parse(url + 'transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> newTransactions = [];

        for (var transaction in data) {
          final Map<String, dynamic> transactionMap =
              transaction as Map<String, dynamic>;
          final category = transactionMap['category'] ?? {};

          final String categoryName = category['name'] ?? 'Unknown';
          final String type = transactionMap['type'] ?? 'Unknown';

          final double amount = transactionMap['amount'] is String
              ? double.tryParse(transactionMap['amount'].replaceAll(',', '')) ??
                  0.0
              : transactionMap['amount'];

          final existingTransactionIndex = newTransactions.indexWhere(
            (t) => t['category_name'] == categoryName && t['type'] == type,
          );

          if (existingTransactionIndex != -1) {
            newTransactions[existingTransactionIndex]['amount'] += amount;
          } else {
            newTransactions.add({
              'category_name': categoryName,
              'category_icon': category['icon'] ?? 'default_icon',
              'category_color': category['color'] ?? '#FFFFFF',
              'amount': amount,
              'date': DateTime.parse(transactionMap['transaction_date']),
              'type': type,
            });
          }
        }

        setState(() {
          transactions = newTransactions;
          _filterTransactions(); // Filter the transactions after fetching
          isLoading = false; // Set loading to false after fetching
        });
      } else {
        errorMessage.value =
            'Failed to fetch transactions. Please try again later.';
        setState(() {
          isLoading = false; // Set loading to false on error
        });
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      setState(() {
        isLoading = false; // Set loading to false on exception
      });
    }
  }

  void _filterTransactions() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Weekly':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Yearly':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'Monthly':
      default:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
    }

    filteredTransactions.value = transactions.where((transaction) {
      return transaction['type'] ==
              (_selectedTab == 0 ? 'Income' : 'Expense') &&
          transaction['date'].isAfter(startDate);
    }).toList();
  }

  void _toggleTab(int index) {
    setState(() {
      _selectedTab = index;
      _filterTransactions(); // Re-filter transactions when the tab is changed
    });
  }

  List<PieChartSectionData> _getChartData() {
    return filteredTransactions.map((transaction) {
      final amount = transaction['amount'];
      final color = transaction['category_color'] is String
          ? Color(int.parse(transaction['category_color'].replaceAll('#', ''),
              radix: 16))
          : transaction['category_color'] as Color;

      return PieChartSectionData(
        color: color,
        value: amount,
      );
    }).toList();
  }

  String get _totalLabelText {
    return _selectedTab == 0 ? 'Total Income' : 'Total Expense';
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final chartData = _getChartData();
    final totalAmount = chartData.fold(0.0, (sum, data) => sum + data.value);

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDark ? Colors.black : const Color.fromARGB(255, 253, 245, 245),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Center(
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isDark
                      ? const Color.fromARGB(255, 71, 69, 69)
                      : const Color(0xFFD9D9D9),
                ),
                child: Row(
                  children: [
                    _buildTabButton("Income", 0, isDark),
                    _buildTabButton("Expense", 1, isDark),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      _selectedPeriod,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: null,
                        items: ['Monthly', 'Weekly', 'Yearly']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPeriod = newValue!;
                            _filterTransactions(); // Re-filter on period change
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 250,
              width: 250,
              child: Totalchart(
                chartData: chartData,
                totalAmount: totalAmount,
                totalLabel: _totalLabelText,
              ),
            ),
            const SizedBox(height: 50),
            Obx(() {
              final currencySymbol =
                  currencyController.selectedCurrency.value.symbol;

              return isLoading // Check if loading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: ((filteredTransactions.length + 1) ~/ 2),
                        itemBuilder: (context, rowIndex) {
                          final firstIndex = rowIndex * 2;
                          final secondIndex = firstIndex + 1;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CategoryCard(
                                  categoryName: filteredTransactions[firstIndex]
                                      ['category_name'],
                                  amount: filteredTransactions[firstIndex]
                                      ['amount'],
                                  color: colorToHex(Color(int.parse(
                                      filteredTransactions[firstIndex]
                                              ['category_color']
                                          .replaceAll('#', ''),
                                      radix: 16))),
                                  categoryIcon: filteredTransactions[firstIndex]
                                      ['category_icon'],
                                  currencySymbol:
                                      currencySymbol, // Here currencySymbol is reactive
                                ),
                                if (secondIndex < filteredTransactions.length)
                                  CategoryCard(
                                    categoryName:
                                        filteredTransactions[secondIndex]
                                            ['category_name'],
                                    amount: filteredTransactions[secondIndex]
                                        ['amount'],
                                    color: colorToHex(Color(int.parse(
                                        filteredTransactions[secondIndex]
                                                ['category_color']
                                            .replaceAll('#', ''),
                                        radix: 16))),
                                    categoryIcon:
                                        filteredTransactions[secondIndex]
                                            ['category_icon'],
                                    currencySymbol: currencySymbol,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
            })
          ],
        ),
      ),
    );
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Widget _buildTabButton(String label, int index, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _selectedTab == index
                ? (isDark ? Colors.white : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _selectedTab == index
                    ? Colors.black
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
