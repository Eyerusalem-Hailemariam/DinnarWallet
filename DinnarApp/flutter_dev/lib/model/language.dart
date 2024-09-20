import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Language {
  final String name;
  final String code; // Added code property
  final Locale locale;

  Language({required this.name, required this.code, required this.locale});

  // List of supported languages
  static List<Language> languages = [
    Language(name: 'English', code: 'en', locale: const Locale('en')),
    Language(name: 'Amharic', code: 'am', locale: const Locale('am')),
    // Add more languages as needed
  ];

  // Get the selected language based on the current locale
  static Language getSelectedLanguage(BuildContext context) {
    Locale currentLocale = Get.locale ?? const Locale('en'); // Default to 'en'
    return languages.firstWhere(
      (lang) => lang.locale == currentLocale,
      orElse: () => languages.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          locale == other.locale;

  @override
  int get hashCode => locale.hashCode;
}
