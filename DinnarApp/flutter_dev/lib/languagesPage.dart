import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'model/language.dart';
import 'controller/language.dart';

class LanguageSelector extends StatefulWidget {
  LanguageSelector({Key? key}) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late Language selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = Language.getSelectedLanguage(Get.context!);
  }

  void changeLanguage(Language? language) {
    if (language == null) return;

    // Update the locale using GetX
    Get.find<LanguageController>().changeLanguage(language.locale);

    setState(() {
      selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double widthFactor = screenWidth / 100;
    double heightFactor = screenHeight / 100;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.1,
          right: screenWidth * 0.1,
          top: screenHeight * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'greeting'.tr, // Use GetX's localization method
              style: TextStyle(fontSize: widthFactor * 5),
            ),
            SizedBox(height: heightFactor * 5),
            DropdownButton<Language>(
              value: selectedLanguage,
              onChanged: (Language? newValue) {
                changeLanguage(newValue);
              },
              items: Language.languages
                  .map<DropdownMenuItem<Language>>((Language language) {
                return DropdownMenuItem<Language>(
                  value: language,
                  child: Text(
                    language.name,
                    style: TextStyle(
                      fontSize: widthFactor * 4.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor: theme.scaffoldBackgroundColor,
              isExpanded: true,
              underline: SizedBox(), // Removes the default underline
              hint: Text('Select Language',
                  style: TextStyle(fontSize: widthFactor * 4.5)),
            ),
            SizedBox(height: heightFactor * 5),
          ],
        ),
      ),
    );
  }
}
