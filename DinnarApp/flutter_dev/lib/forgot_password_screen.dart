import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dev/controller/authentication.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final AuthenticationController _authController =
      Get.put(AuthenticationController());
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'.tr),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 68, 255, 199),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
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
                    )
                  ]),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Email-address'.tr,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            Obx(() {
              if (_authController.isLoading.value) {
                return CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    print(
                        "Email sent to API: $email"); // Trimming to remove spaces
                    if (email.isEmpty) {
                      Get.snackbar('Error', "email_is_required".tr);
                      return;
                    }

                    final success =
                        await _authController.requestPasswordResetCode(email);
                    if (success) {
                      Get.snackbar('Success', "otp_has_been_sent".tr);
                      Get.to(() => ResetPasswordScreen(email: email));
                    } else {
                      Get.snackbar('Error', _authController.errorMessage.value);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 68, 255, 199),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      textStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  child: Text('Send Reset Code'.tr),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
