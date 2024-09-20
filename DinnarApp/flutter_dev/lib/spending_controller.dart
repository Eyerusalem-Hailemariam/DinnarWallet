import 'package:flutter/material.dart';
import 'package:flutter_dev/notification_page.dart';
import 'package:flutter_dev/home_screen.dart';
import 'package:flutter_dev/reminder_page.dart';
import 'package:flutter_dev/statistics.dart';
import 'package:flutter_dev/transactionController.dart';
import 'package:flutter_dev/transaction_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'showadd.dart';
import 'transaction_dialog.dart';
import 'sider_bar.dart';
import 'custom_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'controller/language.dart';
import 'model/language.dart';

void main() {
  // Initialize GetX controllers
  Get.put(TransactionController()); // Initialize the controller

  // Define a default or empty transactions list
  final List<Map<String, dynamic>> transactions = [];

  runApp(
    MaterialApp(
      home: SpendingController(transactions: transactions),
    ),
  );
}

class SpendingController extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const SpendingController({super.key, required this.transactions});

  @override
  // ignore: library_private_types_in_public_api
  _SpendingControllerState createState() => _SpendingControllerState();
}

class _SpendingControllerState extends State<SpendingController> {
  int _selectedIndex = 0;
  int _selectedTab = 0; // 0 for Income, 1 for Expense
  ThemeMode _themeMode = ThemeMode.light;
  String? _selectedCurrency;
  String? _selectedCategory;
  final List<Map<String, dynamic>> _categories = [];
  TextEditingController dateController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final TransactionController controller = Get.find<TransactionController>();
  Language? selectedLanguage;
  final box = GetStorage();
  final languageController = Get.find<LanguageController>();

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();
    String? storedLanguageCode = box.read('languageCode');
    if (storedLanguageCode != null) {
      selectedLanguage = Language.languages
          .firstWhere((language) => language.code == storedLanguageCode);
    } else {
      selectedLanguage = Language.languages.first;
    }
  }

  void _addTransaction(Map<String, dynamic> transaction) {
    controller.addTransaction(transaction);
    print('Transaction added: $transaction');
  }

  void _updateTransaction(Map<String, dynamic> transactionData) {
    // Handle the updated transaction data
    _addTransaction(transactionData);
  }

  void _toggleTheme(int selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
      _themeMode = selectedTab == 0 ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _showAddCategoryDialog(bool isDarkMode) async {
    final categoryData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AddCategoryDialog(isDarkMode: isDarkMode);
      },
    );

    if (categoryData != null) {
      setState(() {
        _categories.add(categoryData);
      });
    }
  }

  void _showAddTransactionDialog() {
    showAddTransactionDialog(
      context,
      _selectedTab,
      _selectedCategory,
      dateController,
      amountController,
      _addTransaction,
      _themeMode == ThemeMode.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> screens = [
      const HomeScreen(),
      Statistics(),
      TransactionScreen(),
      ReminderPage(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      home: Scaffold(
        backgroundColor:
            _themeMode == ThemeMode.dark ? Colors.black : Colors.white,
        appBar: AppBar(
          toolbarHeight: 60,
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<Language>(
                              value: null,
                              onChanged: (Language? newValue) async {
                                if (newValue != null) {
                                  setState(() {
                                    selectedLanguage = newValue;
                                  });
                                  languageController
                                      .changeLanguage(newValue.locale);

                                  box.write('languageCode', newValue.code);

                                  String token = box.read('token') ?? '';
                                  await languageController.updateUserLanguage(
                                      newValue.code, token);
                                }
                              },
                              items:
                                  Language.languages.map((Language language) {
                                return DropdownMenuItem<Language>(
                                  value: language,
                                  child: Text(language.name),
                                );
                              }).toList(),
                              icon: const FaIcon(FontAwesomeIcons.globe),
                              iconSize: screenHeight * 0.028,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 50.0),
                            child: Text(
                              "Langauge".tr,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C4E29),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: screenWidth * 0.04,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPage(
                                onTransactionUpdate: _updateTransaction,
                              ),
                            ),
                          );
                        },
                        icon: const FaIcon(FontAwesomeIcons.bell),
                        iconSize: screenHeight * 0.03,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: Sidebar(
          selectedTab: _selectedTab,
          toggleTheme: _toggleTheme,
          showAddCategoryDialog: _showAddCategoryDialog,
          categories: _categories,
          onCurrencyChanged: (String newValue) {
            setState(() {
              _selectedCurrency = newValue;
            });
          },
        ),
        body: Column(
          children: [
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: screenHeight * 0.04),
          child: SizedBox(
            width: screenHeight * 0.08,
            height: screenHeight * 0.08,
            child: FloatingActionButton(
              onPressed: () {
                _showAddTransactionDialog();
              },
              backgroundColor: const Color(0xFF130F39),
              shape: const CircleBorder(),
              child: Icon(
                CupertinoIcons.add,
                color: const Color.fromARGB(255, 186, 250, 221),
                size: screenHeight * 0.04,
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),
          selectedItemColor:
              _themeMode == ThemeMode.dark ? Colors.white : Colors.black,
          unselectedItemColor: _themeMode == ThemeMode.light
              ? const Color.fromARGB(255, 63, 63, 63)
              : const Color.fromARGB(255, 190, 186, 186),
          type: BottomNavigationBarType.fixed,
          iconSize: screenHeight * 0.03,
          selectedLabelStyle: TextStyle(
            fontSize: screenHeight * 0.015,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: screenHeight * 0.015,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "home".tr,
              activeIcon: Icon(Icons.home, color: Color(0xFFC7FFE6)),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Statistics".tr,
              activeIcon: Icon(Icons.bar_chart, color: Color(0xFFC7FFE6)),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Transactions".tr,
              activeIcon:
                  Icon(Icons.account_balance_wallet, color: Color(0xFFC7FFE6)),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: "Reminder".tr,
              activeIcon: Icon(Icons.event, color: Color(0xFFC7FFE6)),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
