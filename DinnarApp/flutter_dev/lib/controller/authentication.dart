import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dev/screen/onboarding/onboarding_page.dart';
import 'package:flutter_dev/constant/constant.dart';
import '../screen/auth/verify_email_screen.dart';

class AuthenticationController extends GetxController {
  final isLoading = false.obs;
  final token = ''.obs;
  final errorMessage = ''.obs;

  final box = GetStorage();

  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String password_confirmation,
  }) async {
    try {
      isLoading.value = true;
      var data = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password_confirmation,
      };
      var response = await http.post(
        Uri.parse(url + 'register'),
        headers: {
          'Accept': 'application/json',
        },
        body: data,
      );
      isLoading.value = false;
      if (response.statusCode == 201) {
        print(json.decode(response.body));
        return true;
      } else {
        final body = json.decode(response.body);
        print('Error response body: ${body}');
        errorMessage.value = body['errors']?['email'] ??
            body['errors']?['phone'] ??
            'Registration failed. Please try again.';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      print('Exception: ${e.toString()}');
      errorMessage.value = 'An unexpected error occurred.';
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final data = jsonEncode({
        'email': email,
        'password': password,
      });

      final response = await http.post(
        Uri.parse(url + 'login'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: data,
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        token.value = responseBody['token'];
        final userId = responseBody['user_id'];
        final userEmail = responseBody['email'];
        final isEmailVerified = responseBody['is_email_verified'];

        box.write('token', token.value);
        box.write('user_id', userId);
        box.write('email', userEmail);

        // Check if the email is verified
        if (isEmailVerified == false) {
          // Navigate to the Verify Email Screen if the email is not verified
          Get.to(() => VerifyEmailScreen());
          return false; // Indicate that login was not fully successful due to unverified email
        }

        return true;
      } else if (response.statusCode == 403) {
        Get.to(() =>
            VerifyEmailScreen()); // If specific response indicates unverified email
        return false;
      } else {
        final body = json.decode(response.body);
        errorMessage.value =
            body['message'] ?? 'Login failed. Please try again.';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred.';
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final token = box.read('token') ?? '';
      final response = await http.post(
        Uri.parse(url + 'logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        box.remove('token');
        Get.offAll(() => const OnboardingPage());
      } else {
        Get.snackbar('Error', 'Logout failed: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<bool> requestPasswordResetCode(String email) async {
    try {
      isLoading.value = true;
      var response = await http.post(
        Uri.parse(url + 'forgot-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json' // Ensure this header is set
        },
        body: jsonEncode({'email': email}),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = json.decode(response.body);
        errorMessage.value = body['message'] ??
            'Failed to send verification code. Please try again.';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred.';
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String resetCode, // Ensure this matches the backend
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;

      // Construct the request body
      var body = jsonEncode({
        'email': email,
        'reset_code':
            resetCode, // Make sure this matches the backend field name
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      // Send the POST request
      var response = await http.post(
        Uri.parse(url + 'reset-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      isLoading.value = false;

      // Check the response status
      if (response.statusCode == 200) {
        return true;
      } else {
        final body = json.decode(response.body);
        errorMessage.value =
            body['message'] ?? 'Reset password failed. Please try again.';
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred.';
      return false;
    }
  }

  Future<int?> addCategory({
    required String categoryName,
    required String categoryIcon,
    required String categoryColor,
  }) async {
    try {
      final userId = box.read('user_id'); // Ensure user_id is not null
      if (userId == null) {
        throw Exception('User ID is null');
      }
      // Ensure user_id is saved in the box
      final response = await http.post(
        Uri.parse(url + 'categories'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': categoryName,
          'icon': categoryIcon,
          'color': categoryColor,
          'user_id': userId, // Include user_id here
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        return body['id'];
      } else {
        final body = json.decode(response.body);
        errorMessage.value =
            body['message'] ?? 'Failed to add category. Please try again.';
        return null;
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'An unexpected error occurred.';
      return null;
    }
  }

  Future<bool> addTransaction({
    required int selectedCategoryId,
    required double transactionAmount,
    required String selectedDate,
    required String transactionType,
  }) async {
    try {
      final userId = box.read('user_id'); // Ensure user_id is not null
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await http.post(
        Uri.parse(url + 'transactions'),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'category_id': selectedCategoryId,
          'transaction_date': selectedDate,
          'amount': transactionAmount,
          'type': transactionType,
          'user_id': userId, // Include user_id here
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final body = json.decode(response.body);
        errorMessage.value =
            body['message'] ?? 'Failed to add transaction. Please try again.';
        return false;
      }
    } catch (e) {
      print('Error: $e');
      errorMessage.value = 'An unexpected error occurred.';
      return false;
    }
  }

  Future<ApiResponse> verifyEmailAPI(String code) async {
    try {
      final response = await http.post(
        Uri.parse(url + 'verify-email'),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'verification_code': code,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Email verified');
      } else {
        // Log the response body for debugging
        print('Error response body: ${response.body}');
        return ApiResponse(success: false, message: 'Verification failed');
      }
    } catch (e) {
      print('Error: $e'); // Log the error for debugging
      return ApiResponse(success: false, message: 'An error occurred');
    }
  }
}

class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});
}
