import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/language.dart'; // Ensure these are correctly defined and imported
import 'transactionController.dart'; // Ensure these are correctly defined and imported
import 'language_translations.dart'; // Ensure these are correctly defined and imported
import 'welcome_screen.dart'; // Ensure these are correctly defined and imported
import 'onboarding_page.dart';
import 'custom_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/currency.dart';
import 'controller/reminder.dart';
// Ensure these are correctly defined and imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Create instances of controllers
  final languageController = Get.put(LanguageController());
  final transactionController = Get.put(TransactionController());
  Get.put(CurrencyController());

  // Retrieve token from GetStorage
  final box = GetStorage();
  String token = box.read('token') ?? '';

  // Fetch the user's language preference
  await languageController.fetchUserLanguage(token);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final String? storedLanguageCode = box.read('languageCode');

    // Set initial locale based on stored language
    final Locale initialLocale = storedLanguageCode != null
        ? Locale(storedLanguageCode)
        : Get.deviceLocale ?? Locale('en');

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: [Locale('en'), Locale('am')],
      locale: initialLocale,
      localizationsDelegates: [
        CustomLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      fallbackLocale: const Locale('en'),
      debugShowCheckedModeBanner: false,
      translations: LanguageTranslations(),
      home: MainPageView(),
    );
  }
}

class MainPageView extends StatelessWidget {
  final PageController _pageController = PageController();

  MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const [
          WelcomeScreen(),
          OnboardingPage(),
        ],
      ),
    );
  }
}
