import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomLocalizations {
  final Locale locale;

  CustomLocalizations(this.locale);

  static CustomLocalizations? of(BuildContext context) {
    return Localizations.of<CustomLocalizations>(context, CustomLocalizations);
  }

  String get someLocalizedText {
   
    Map<String, String> localizedStrings = {
      'en': 'Hello',
      'am': 'ሰላም', 
    };

   
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
    
    return SynchronousFuture<CustomLocalizations>(CustomLocalizations(locale));
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}

class GetXLocalizations {
  static Future<void> load(Locale locale) async {
    
  }

 
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
