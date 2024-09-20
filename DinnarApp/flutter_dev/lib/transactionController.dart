import 'package:get/get.dart';

class TransactionController extends GetxController {
  var transactions = <Map<String, dynamic>>[].obs;
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  var deletedTransactions = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _calculateTotals();
  }

  void setTransactions(List<Map<String, dynamic>> newTransactions) {
    transactions.value = newTransactions;
  }

 

 
  void addTransaction(Map<String, dynamic> transactionData) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    transactionData['id'] = id;
    transactions.add(transactionData);
    _calculateTotals();
    print('Transaction added: $transactionData');
  }

  void removeTransaction(String transactionId) {
    if (transactionId.isEmpty) {
      print('Transaction ID is null or empty. Cannot remove transaction.');
      print(
          'All transactions: ${transactions.toList()}'); // Print all transactions for debugging
      return;
    }
    print('Attempting to remove transaction with ID: $transactionId');
    transactions
        .removeWhere((transaction) => transaction['id'] == transactionId);
    print(
        'Transaction removed. Remaining transactions: ${transactions.length}');
    _calculateTotals();
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
