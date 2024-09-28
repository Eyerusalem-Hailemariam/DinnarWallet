import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dev/controller/authentication.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dev/screen/auth/forgot_password_screen.dart';
import 'package:flutter_dev/screen/signup/signupp.dart';
import 'package:flutter_dev/spending_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../controller/language.dart';
import '../../model/language.dart';

class LoginP extends StatefulWidget {
  const LoginP({super.key});

  @override
  State<LoginP> createState() => _LoginPState();
}

class _LoginPState extends State<LoginP> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthenticationController _authenticationController =
      Get.put(AuthenticationController());
  Language? selectedLanguage;
  final box = GetStorage();
  final languageController = Get.find<LanguageController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if (!isEmailValid) {
      return "Please enter a valid".tr;
    } else if (email == null || email.isEmpty) {
      return 'email_is_required'.tr;
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "password_is_required".tr;
    } else if (password.length < 8) {
      return 'password_length_error'.tr;
    }
    return null;
  }

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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal:
                    isLargeScreen ? screenWidth * 0.25 : screenWidth * 0.0238,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.08),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.2,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Text(
                          "Login".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: screenHeight * 0.03,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  RichText(
                    text: TextSpan(
                      text: 'Dont have account ?'.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * 0.018,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up".tr,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: screenHeight * 0.02,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpp(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        LabeledInputField(
                          label: 'Email-address'.tr,
                          hintText: "Example@gmail.com",
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.w400,
                          borderColor: Colors.grey[300],
                          borderWidth: 0.5,
                          fillColor: const Color(0xFFF2F2F6),
                          validator: validateEmail,
                          controller: _emailController,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        LabeledInputField(
                          label: 'Password'.tr,
                          hintText: "**********",
                          fontSize: screenHeight * 0.018,
                          obscureText: true,
                          fontWeight: FontWeight.w400,
                          borderColor: Colors.grey[300],
                          borderWidth: 0.5,
                          fillColor: const Color(0xFFF2F2F6),
                          validator: validatePassword,
                          controller: _passwordController, // Add this line
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => ForgotPasswordScreen());
                                },
                                child: Text('Forgot Password?'.tr,
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05),
                          child: MaterialButton(
                            height: screenHeight * 0.07,
                            minWidth: double.infinity,
                            color: const Color(0xFF130F39),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success =
                                    await _authenticationController.login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );

                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpendingController(
                                        transactions: [], // Provide an appropriate list or replace with dynamic data
                                      ),
                                    ),
                                  );
                                } else {
                                  // Handle login error
                                  String errorMessage =
                                      _authenticationController
                                          .errorMessage.value;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                    ),
                                  );
                                }
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Obx(() {
                              return _authenticationController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Login".tr,
                                      style: TextStyle(
                                        color: const Color(0xFFC7FFE6),
                                        fontSize: screenHeight * 0.022,
                                      ),
                                    );
                            }),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LabeledInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? borderColor;
  final double borderWidth;
  final Color? fillColor;
  final String? Function(String?)? validator;
  final TextEditingController? controller; // Add this line

  const LabeledInputField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.borderColor,
    this.borderWidth = 1.0,
    this.fillColor,
    this.validator,
    this.controller, // Add this line
  });

  @override
  _LabeledInputFieldState createState() => _LabeledInputFieldState();
}

class _LabeledInputFieldState extends State<LabeledInputField> {
  bool _hasError = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label.substring(0, widget.label.length - 1),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: Colors.black,
                fontWeight: widget.fontWeight,
              ),
              children: [
                TextSpan(
                  text: widget.label.substring(widget.label.length - 1),
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          TextFormField(
            controller: widget.controller, // Add this line
            obscureText: widget.obscureText ? _obscureText : false,
            validator: (value) {
              String? error = widget.validator!(value);
              setState(() {
                _hasError = error != null;
              });
              return error;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.borderColor ?? Colors.transparent,
                  width: widget.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.borderColor ?? Colors.transparent,
                  width: widget.borderWidth,
                ),
              ),
              hintText: _hasError ? '' : widget.hintText,
              hintStyle: TextStyle(
                fontSize: screenHeight * 0.015,
                color: const Color.fromARGB(255, 105, 115, 128),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: 10,
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      iconSize: screenHeight * 0.025,
                      color: Colors.black87,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: LoginP(),
  ));
}
