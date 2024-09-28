import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constant/constant.dart';
import 'dart:convert';

class TransactionController extends GetxController {
  var transactions = <Map<String, dynamic>>[].obs;
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  var deletedTransactions = <String>{}.obs;
  RxString limitReachedMessage = ''.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _calculateTotals();
    fetchTransactions();
    deletedTransactions();
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
        setTransactions(transactions);
        totalIncome = totalIncome;
        totalExpense = totalExpense;
      } else {
        errorMessage.value =
            'Failed to fetch transactions. Please try again later.';
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'An unexpected error occurred.';
    }
  }

  void setTransactions(List<Map<String, dynamic>> newTransactions) {
    transactions.value = newTransactions;
  }

  void updateLimitReachedMessage(String message) {
    limitReachedMessage.value = message;
  }

  void addTransaction(Map<String, dynamic> transactionData) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    transactionData['id'] = id;

    // Add the transaction locally first
    transactions.add(transactionData);

    // Calculate totals immediately
    _calculateTotals();

    // Refresh the transactions list to ensure reactivity
    transactions.refresh();

    // Optionally, fetch transactions again to sync with the server
    fetchTransactions();

    print('Transaction added: $transactionData');
  }

  void removeTransaction(String transactionId) {
    if (transactionId.isEmpty) {
      print('Transaction ID is null or empty. Cannot remove transaction.');
      return;
    }

    // Remove the transaction locally first
    transactions
        .removeWhere((transaction) => transaction['id'] == transactionId);

    // Calculate totals immediately
    _calculateTotals();

    // Refresh the transactions list to ensure reactivity
    transactions.refresh();

    // Optionally, fetch transactions again to sync with the server
    fetchTransactions();

    print(
        'Transaction removed. Remaining transactions: ${transactions.length}');
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
        _calculateTotals();
      } else {
        // Handle server error
        print('Failed to delete transaction.');
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    for (var transaction in transactions) {
      final amount = double.tryParse(transaction['amount'].toString()) ?? 0.0;
      if (transaction['type'] == 'Income') {
        income += amount;
      } else if (transaction['type'] == 'Expense') {
        expense += amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
  }

  // Method to update the list of transactions

  void printTransactions() {
    transactions.forEach((transaction) {
      print('Transaction: ${transaction.toString()}');
    });
  }

  void updateTransaction(String id, Map<String, dynamic> updatedData) {
    final index = transactions.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      transactions[index] = {...transactions[index], ...updatedData};
      print('Updated transaction with ID: $id');
      transactions.refresh(); // Ensure UI is refreshed
    } else {
      print('Transaction with ID: $id not found.');
    }
  }

  // Flag a transaction as deleted locally
  void removeTransactionLocally(String transactionId) {
    deletedTransactions.add(transactionId);
  }

  // Check if a transaction is marked as deleted
  bool isTransactionDeleted(String transactionId) {
    return deletedTransactions.contains(transactionId);
  }
}
