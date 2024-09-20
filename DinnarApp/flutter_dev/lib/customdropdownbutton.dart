import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final T selectedValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Widget icon;
  final Color iconBackgroundColor;

  const CustomDropdownButton({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.icon,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: selectedValue,
        items: items,
        onChanged: onChanged,
        icon: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        isExpanded: true,
      ),
    );
  }
}
