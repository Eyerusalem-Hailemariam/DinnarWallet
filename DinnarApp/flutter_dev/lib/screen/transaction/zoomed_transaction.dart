import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controller/currency.dart';
import '../../model/currency.dart';

class ZoomedTransactionPage extends StatefulWidget {
  final List<dynamic> transactions;

  const ZoomedTransactionPage({
    required this.transactions
    });

  @override
  State<ZoomedTransactionPage> createState() => _ZoomedTransactionPageState();
}

class _ZoomedTransactionPageState extends State<ZoomedTransactionPage> {
  late TextEditingController _searchController;
  late List<dynamic> _filteredTransactions;
  late List<dynamic> _allTransactions;
  int _selectedTab = 0;
  final CurrencyController currencyController = Get.find<CurrencyController>();
  Currency? selectedCurrency;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allTransactions = widget.transactions;
    _filteredTransactions = _allTransactions;
    final storedCurrencyCode = GetStorage().read('selectedCurrency');
    if (storedCurrencyCode != null) {
      currencyController.selectedCurrency.value = Currency.currencies
          .firstWhere((currency) => currency.code == storedCurrencyCode);
    }
    _searchController.addListener(() {
      _filterTransactions();
    });
  }

  void _toggleTab(int selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
      _filterTransactions(); // Filter transactions when the tab is changed
    });
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Check if the transaction type matches the selected tab
        final isTypeMatch = _selectedTab == 0
            ? transaction['type'] == 'Income'
            : transaction['type'] == 'Expense';

        // Check if the search query matches either category name or transaction date
        final isSearchMatch = query.isEmpty ||
            (transaction['category_name'] ?? '')
                .toLowerCase()
                .contains(query) ||
            (transaction['transaction_date'] ?? '')
                .toLowerCase()
                .contains(query);

        return isTypeMatch && isSearchMatch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Transactions'.tr,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 68, 255, 199),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDark
                  ? const Color.fromARGB(255, 71, 69, 69)
                  : const Color(0xFFD9D9D9),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleTab(0),
                    child: SizedBox(
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 40,
                            width: 115,
                            decoration: BoxDecoration(
                              color: _selectedTab == 0
                                  ? (isDark ? Colors.black : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _selectedTab == 0
                                    ? (isDark ? Colors.black : Colors.white)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Income".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleTab(1),
                    child: SizedBox(
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 40,
                            width: 115,
                            decoration: BoxDecoration(
                              color: _selectedTab == 1
                                  ? (isDark ? Colors.black : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _selectedTab == 1
                                    ? (isDark ? Colors.black : Colors.white)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Expense".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by category or date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterTransactions();
              },
            ),
          ),
          Obx(() {
            final currencySymbol =
                currencyController.selectedCurrency.value.symbol;
            return Expanded(
              child: ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];
                  final categoryName =
                      transaction['category_name'] ?? 'Unknown Category';
                  final transactionDate =
                      transaction['transaction_date'] ?? 'Unknown Date';
                  final amount = transaction['amount'] != null
                      ? double.tryParse(transaction['amount'].toString()) ?? 0.0
                      : 0.0;
                  final categoryColor = transaction['category_color'] != null
                      ? colorFromHex(transaction['category_color'])
                      : Colors.grey;
                  final categoryIcon =
                      transaction['category_icon'] ?? 'default_icon';
                  final isIncome = transaction['type'] == 'Income';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categoryColor,
                      child: Image.asset(
                        'assets/images/$categoryIcon.png',
                        width: 30,
                        height: 30, 
                      ),
                    ),
                    title: Text(categoryName),
                    subtitle: Text(transactionDate),
                    trailing: Text(
                      '${transaction['type'] == 'Income' ? '+' : '-'}$currencySymbol${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontSize: 18),
                    ),
                  );
                },
              ),
            );
          }),
        ],
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
