import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../constant/constant.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  final box = GetStorage();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if new password and confirm password match
      if (newPassword != confirmPassword) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }

      // Fetch the token from GetStorage
      final token = box.read('token');
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      // Send the change password request
      try {
        final response = await http.post(
          Uri.parse(
              url + 'change-password'), // Ensure `url` is correctly defined
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'current_password': currentPassword,
            'new_password': newPassword,
          }),
        );

        // Handle response
        if (response.statusCode == 200) {
          Get.snackbar('Success', 'Password changed successfully');
        } else if (response.statusCode == 400) {
          // If 400, show error message
          final responseBody = json.decode(response.body);
          Get.snackbar(
              'Error', responseBody['error'] ?? 'Failed to change password');
        } else {
          // For other status codes, show a generic error message
          Get.snackbar('Error', 'Failed to change password. Please try again.');
        }
      } catch (error) {
        // Handle network or server errors
        Get.snackbar('Error', 'An error occurred: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 68, 255, 199),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildPasswordField("Current Password", (value) {
                  currentPassword = value;
                }),
                const SizedBox(height: 20),
                _buildPasswordField("New Password", (value) {
                  newPassword = value;
                }),
                const SizedBox(height: 20),
                _buildPasswordField("Confirm Password", (value) {
                  confirmPassword = value;
                }),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text(
                    "Change Password",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 255, 199),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, Function(String) onSaved) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        obscureText: true,
        onSaved: (value) => onSaved(value!),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
