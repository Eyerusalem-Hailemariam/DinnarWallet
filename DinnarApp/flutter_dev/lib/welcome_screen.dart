import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    return Scaffold(
      backgroundColor: const Color(0xFFC7FFE6),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFC7FFE6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 280),
              Column(
                children: [
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 1,
                      effect: const WormEffect(
                        dotWidth: 200,
                        dotHeight: 6,
                        activeDotColor:  Color(0xFF130F39),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
