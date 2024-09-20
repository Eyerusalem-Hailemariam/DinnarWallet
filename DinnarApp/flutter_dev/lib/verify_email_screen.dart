import 'package:flutter/material.dart';
import 'package:flutter_dev/controller/authentication.dart';
import 'package:get/get.dart';
import 'spending_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  final AuthenticationController _authController =
      Get.find<AuthenticationController>();

  void _verifyEmail() async {
    final code = _codeController.text;

    final response = await _authController.verifyEmailAPI(code);

    if (response.success) {
      Get.offAll(() => SpendingController(
            transactions: [],
          )); // Navigate to SpendingController and clear navigation stack
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("verify_email".tr),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 68, 255, 199),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              'Enter the verification code sent to your email:'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
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
                controller: _codeController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Verification Code'.tr,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 68, 255, 199),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text('Verify'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
