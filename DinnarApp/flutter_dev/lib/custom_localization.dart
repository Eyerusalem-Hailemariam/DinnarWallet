import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomLocalizations {
  final Locale locale;

  CustomLocalizations(this.locale);

  static CustomLocalizations? of(BuildContext context) {
    return Localizations.of<CustomLocalizations>(context, CustomLocalizations);
  }

  String get someLocalizedText {
    // Define translations for different locales
    Map<String, String> localizedStrings = {
      'en': 'Hello',
      'am': 'ሰላም', // Amharic translation for 'Hello'
      // Add more translations for other locales
    };

    // Return the localized string based on the locale
    return localizedStrings[locale.languageCode] ?? 'Default text';
  }
}

class CustomLocalizationsDelegate
    extends LocalizationsDelegate<CustomLocalizations> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'am'].contains(locale.languageCode);

  @override
  Future<CustomLocalizations> load(Locale locale) {
    // Initialize CustomLocalizations with the provided locale
    return SynchronousFuture<CustomLocalizations>(CustomLocalizations(locale));
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}

class GetXLocalizations {
  static Future<void> load(Locale locale) async {
    // Load localization data here
    // This is where you can load your translations, for example from assets or an API
  }

  // Add methods to fetch translations
}

class GetXLocalizationsDelegate
    extends LocalizationsDelegate<GetXLocalizations> {
  const GetXLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<GetXLocalizations> load(Locale locale) async {
    await GetXLocalizations.load(locale);
    return GetXLocalizations();
  }

  @override
  bool shouldReload(GetXLocalizationsDelegate old) => false;
}
