import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/constant.dart';

class LanguageController extends GetxController {
  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
  }

  // Send the language update to the server
  Future<void> updateUserLanguage(String language, String token) async {
    try {
      final response = await http.post(
        Uri.parse(url + 'user/update-language'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'language': language}),
      );

      if (response.statusCode == 200) {
        // Handle success
        print('Language updated successfully');
      } else {
        // Handle failure
        print('Failed to update language: ${response.body}');
      }
    } catch (e) {
      // Handle any errors during the request
      print('Error updating language: $e');
    }
  }

  Future<void> fetchUserLanguage(String token) async {
    try {
      final response = await http.get(
        Uri.parse(url + 'user/language'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the language from the response
        final data = jsonDecode(response.body);
        final language = data['language'];

        // Update the locale based on the fetched language
        if (language == 'en') {
          changeLanguage(Locale('en', 'US'));
        } else if (language == 'am') {
          changeLanguage(Locale('am', ''));
        }
        // Add more language cases as needed
      } else {
        // Handle failure
        print('Failed to fetch language: ${response.body}');
      }
    } catch (e) {
      // Handle any errors during the request
      print('Error fetching language: $e');
    }
  }
}
