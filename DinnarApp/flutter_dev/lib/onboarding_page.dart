import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/language.dart';
import 'model/language.dart';
import 'custom_clipper.dart';
import 'signupp.dart';
import 'login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();
  Language? selectedLanguage;
  final languageController = Get.find<LanguageController>();
  final box = GetStorage(); // For accessing stored token and language

  @override
  void initState() {
    super.initState();
    // Initialize the selected language from local storage
    String? storedLanguageCode = box.read('languageCode');
    if (storedLanguageCode != null) {
      selectedLanguage = Language.languages
          .firstWhere((language) => language.code == storedLanguageCode);
    } else {
      // If no language is stored, use a default language or let user choose again
      selectedLanguage = Language.languages.first;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ClipPath(
                  clipper: CustomClipperWidget(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: MediaQuery.of(context).size.width,
                    child: PageView(
                      controller: controller,
                      children: [
                        OnboardingContent(
                          color: const Color(0xFFC7FFE5),
                          title: 'onboarding.title1'.tr,
                          subtitle: 'onboarding.subtitle1'.tr,
                          backgroundColor: const Color(0xFFC7FFE6),
                          walletImage: 'assets/images/flutter_wallet2.png',
                        ),
                        OnboardingContent(
                          color: const Color(0xFFC7FFE5),
                          title: 'onboarding.title2'.tr,
                          subtitle: 'onboarding.subtitle2'.tr,
                          backgroundColor: Colors.blueAccent,
                          walletImage: 'assets/images/example_image_2.png',
                        ),
                        OnboardingContent(
                          color: const Color(0xFFC7FFE5),
                          title: 'onboarding.title3'.tr,
                          subtitle: 'onboarding.subtitle3'.tr,
                          backgroundColor: Colors.black87,
                          walletImage: 'assets/images/example_image_2.png',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSocialLogins(context),
            ],
          ),
          Positioned(
            bottom: 220, // Adjust as needed
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: CustomizableEffect(
                  activeDotDecoration: DotDecoration(
                    width: 35.6,
                    height: 8.07,
                    color: const Color(0xFF130F39),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  dotDecoration: DotDecoration(
                    width: 9.5,
                    height: 8.07,
                    color: const Color(0xFF130F39),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  spacing: 4,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 15,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Language>(
                value: null,
                onChanged: (Language? newValue) async {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                    });
                    languageController.changeLanguage(newValue.locale);

                    // Store selected language locally
                    box.write('languageCode', newValue.code);

                    // Retrieve token from GetStorage
                    String token = box.read('token') ?? '';

                    // Update user language in the backend
                    await languageController.updateUserLanguage(
                        newValue.code, token);
                  }
                },
                items: Language.languages.map((Language language) {
                  return DropdownMenuItem<Language>(
                    value: language,
                    child: Text(language.name),
                  );
                }).toList(),
                icon: const FaIcon(FontAwesomeIcons.globe),
                iconSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final Color color;
  final String? imageAsset;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String walletImage;
  final Alignment imageAlignment;
  final Widget? child;

  const OnboardingContent({
    Key? key,
    required this.color,
    this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.walletImage,
    this.imageAlignment = Alignment.center,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Align(
                alignment: imageAlignment,
                child: Center(
                  child: Container(
                    color: backgroundColor,
                    child: Image.asset(walletImage),
                  ),
                ),
              ),
            ),
            Text(
              '       $title',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ' $subtitle',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

Widget _buildSocialLogins(BuildContext context) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                height: 56,
                color: const Color(0xFF130F39),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpp()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "buttons.signUp".tr,
                  style: TextStyle(
                    color: Color(0xFFC7FFE6),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                height: 56,
                color: const Color(0xFFC7FFE5),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginP()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "buttons.login".tr,
                  style: TextStyle(
                    color: Color(0xFF130F39),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
