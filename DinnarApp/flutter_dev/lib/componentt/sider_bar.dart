import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dev/screen/profile/EditProfile.dart';
import 'package:flutter_dev/screen/auth/change_password.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controller/currency.dart';
import '../controller/authentication.dart';
import '../model/currency.dart';
import '../controller/user.dart';

class Sidebar extends StatelessWidget {
  final int selectedTab;
  final Function(int) toggleTheme;
  final void Function(bool) showAddCategoryDialog;
  final List<Map<String, dynamic>> categories;
  final Function(String) onCurrencyChanged;

  const Sidebar({
    Key? key,
    required this.selectedTab,
    required this.toggleTheme,
    required this.showAddCategoryDialog,
    required this.categories,
    required this.onCurrencyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    final AuthenticationController authController =
        Get.find<AuthenticationController>();
    final UserController userController = Get.put(UserController());

    bool isDarkMode = selectedTab == 1;

    return Drawer(
      child: Container(
        color:
            isDarkMode ? const Color.fromARGB(255, 71, 69, 69) : Colors.white,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 220,
              child: DrawerHeader(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                toggleTheme(isDarkMode ? 0 : 1);
                              },
                              icon: FaIcon(
                                isDarkMode
                                    ? FontAwesomeIcons.cloudSun
                                    : CupertinoIcons.moon,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              iconSize: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1))
                            ]),
                        child: Icon((CupertinoIcons.person)),
                      ),
                      title: Obx(() {
                        if (userController.isLoading.value) {
                          return Text('Loading...');
                        } else {
                          return Text(userController.user.value.name.isNotEmpty
                              ? userController.user.value.name
                              : 'No Name');
                        }
                      }),
                      subtitle: Obx(() {
                        if (userController.isLoading.value) {
                          return Text('Loading...');
                        } else {
                          return Text(userController.user.value.email.isNotEmpty
                              ? userController.user.value.email
                              : 'No Email');
                        }
                      }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Editprofile()));
                          },
                          child: Text('Edit Profile'.tr,
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF130F39),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF333333)
                      : const Color(0xFFEEEEEE),
                ),
              ),
            ),
            SizedBox(
              height: 6,
            ),
            ListTile(
              title: Text('Set Currency'.tr,
                  style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black)),
              trailing: Obx(() => DropdownButton<String>(
                    value: currencyController.selectedCurrency.value.code,
                    items: Currency.currencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency.code,
                        child: Text(currency.code),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        final selected = Currency.currencies.firstWhere(
                            (currency) => currency.code == newValue);
                        currencyController.changeCurrency(selected);
                        onCurrencyChanged(newValue);
                      }
                    },
                  )),
            ),
            ListTile(
              title: Text("Add Category".tr,
                  style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                showAddCategoryDialog(isDarkMode);
              },
            ),
            ListTile(
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePassword()));
                },
                child: Text("ChangePassword".tr,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16)),
              ),
            ),
            ListTile(
              title: GestureDetector(
                onTap: () {
                  authController.logout();
                },
                child: Text("logout".tr,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
