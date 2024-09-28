import 'package:flutter/material.dart';

class CustomTheme {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: const Color(0xFF130F39),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFFC7FFE5),
      unselectedItemColor: Colors.black,
      selectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF130F39),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFFC7FFE5),
      unselectedItemColor: Colors.white,
      selectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFC7FFE6),
      ),
    ),
  );
}
