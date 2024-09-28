import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dev/controller/authentication.dart';

import 'package:flutter_dev/screen/auth/verify_email_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../login/login_screen.dart';
import 'package:get_storage/get_storage.dart';
import '../../controller/language.dart';
import '../../model/language.dart';

class SignUpp extends StatefulWidget {
  const SignUpp({super.key});

  @override
  State<SignUpp> createState() => _SignUppState();
}

class _SignUppState extends State<SignUpp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthenticationController _authenticationController =
      Get.put(AuthenticationController());
  Language? selectedLanguage;
  final languageController = Get.find<LanguageController>();

  final box = GetStorage();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_is_required'.tr;
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid".tr;
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "password_is_required".tr;
    } else if (password.length < 8) {
      return "password_length_error".tr;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Initialize the selected language (if needed)
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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.03,
            right: screenWidth * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DropdownButtonHideUnderline(
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
              Center(
                child: SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.13,
                  child: const Image(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create your account".tr,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 59, 59, 65),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: 'Already have account'.tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: "Login".tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginP(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    LabeledInputField(
                      label: "Full name".tr,
                      hintText: "Hayat Tofik",
                      controller: _nameController,
                      fontSize: 14,
                      borderColor: Colors.grey[300],
                      borderWidth: 0.5,
                      fillColor: const Color(0xFFF2F2F6),
                    ),
                    const SizedBox(height: 12),
                    LabeledInputField(
                      label: "Email-address".tr,
                      hintText: "Example@gmail.com",
                      controller: _emailController,
                      fontSize: 14,
                      borderColor: Colors.grey[300],
                      borderWidth: 0.5,
                      fillColor: const Color(0xFFF2F2F6),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 12),
                    LabeledInputField(
                      label: "Phone Number".tr,
                      hintText: "0911615888",
                      controller: _phoneController,
                      fontSize: 14,
                      borderColor: Colors.grey[300],
                      borderWidth: 0.5,
                      fillColor: const Color(0xFFF2F2F6),
                    ),
                    const SizedBox(height: 12),
                    LabeledInputField(
                      label: "Password".tr,
                      hintText: "**********",
                      controller: _passwordController,
                      obscureText: true,
                      fontSize: 14,
                      borderColor: Colors.grey[300],
                      borderWidth: 0.5,
                      fillColor: const Color(0xFFF2F2F6),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 12),
                    LabeledInputField(
                      label: "Confirm Password".tr,
                      hintText: "**********",
                      controller: _confirmPasswordController,
                      obscureText: true,
                      fontSize: 14,
                      borderColor: Colors.grey[300],
                      borderWidth: 0.5,
                      fillColor: const Color(0xFFF2F2F6),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success =
                                await _authenticationController.register(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                              password: _passwordController.text.trim(),
                              password_confirmation:
                                  _confirmPasswordController.text.trim(),
                            );
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyEmailScreen(
                                      // Provide an appropriate list or replace with dynamic data
                                      ),
                                ),
                              );
                            } else {
                              // Handle registration error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Obx(() {
                                    return Text(_authenticationController
                                        .errorMessage.value);
                                  }),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF130F39),
                          minimumSize:
                              Size(double.infinity, screenHeight * 0.063),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Obx(() {
                          return _authenticationController.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  "Sign Up".tr,
                                  style: TextStyle(
                                    color: Color(0xFFC7FFE6),
                                    fontSize: 18,
                                  ),
                                );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LabeledInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final double fontSize;
  final Color? borderColor;
  final double borderWidth;
  final Color? fillColor;
  final String? Function(String?)? validator;

  const LabeledInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.fontSize = 14,
    this.borderColor,
    this.borderWidth = 1.0,
    this.fillColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: fontSize),
              filled: true,
              fillColor: fillColor,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                  width: borderWidth,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                  width: borderWidth,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
