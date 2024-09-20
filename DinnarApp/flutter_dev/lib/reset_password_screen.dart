import 'package:flutter/material.dart';
import 'package:flutter_dev/spending_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_dev/controller/authentication.dart';


class ResetPasswordScreen extends StatelessWidget {
  final AuthenticationController _authController = Get.find();
  final String email;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  ResetPasswordScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("reset_password".tr),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 68, 255, 199),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Reset Code'.tr),
                obscureText: true,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'New Password'.tr),
                obscureText: true,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(labelText: 'Confirm Password'.tr),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (_authController.isLoading.value) {
                return CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    final code = _codeController.text;
                    final password = _passwordController.text;
                    final passwordConfirm = _passwordConfirmController.text;
                    final success = await _authController.resetPassword(
                      email: email,
                      resetCode: code,
                      password: password,
                      passwordConfirmation: passwordConfirm,
                    );
                    if (success) {
                      Get.snackbar('Success', "password_reset_successful".tr);
                      Get.offAll(() => SpendingController(
                            transactions: [],
                          ));
                    } else {
                      Get.snackbar('Error', _authController.errorMessage.value);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 255, 199),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text("reset_password".tr),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
