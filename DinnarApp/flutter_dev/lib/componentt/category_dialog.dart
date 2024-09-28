import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/cupertino.dart';
import '../../controller/authentication.dart'; // Import the controller
import 'package:get/get.dart'; // Import GetX

class AddCategoryDialog extends StatefulWidget {
  final bool isDarkMode;

  const AddCategoryDialog({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();
  bool isExpanded = false;
  String iconSelected = '';
  late Color categoryColor;
  final AuthenticationController _authController =
      Get.find(); // Create an instance of the controller

  List<String> myCategoriesIcons = [
    'buying',
    'game1',
    'hamburger',
    'pet1',
    'rental',
    'tech',
    'route',
    'car'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize categoryColor based on the theme mode
    categoryColor = widget.isDarkMode ? Colors.grey[800]! : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode
          ? const Color.fromARGB(255, 54, 50, 50)
          : const Color.fromARGB(255, 204, 211, 223),
      title: Text(
        "Create a Category".tr,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _categoryController,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor:
                      widget.isDarkMode ? Colors.grey[800] : Colors.white,
                  hintText: "Name".tr,
                  hintStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                textAlignVertical: TextAlignVertical.center,
                readOnly: true,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor:
                      widget.isDarkMode ? Colors.grey[800] : Colors.white,
                  hintText: "Icon".tr,
                  hintStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  suffixIcon: iconSelected.isNotEmpty
                      ? Image.asset(
                          'assets/images/$iconSelected.png',
                          width: 24,
                          height: 24,
                        )
                      : const Icon(CupertinoIcons.chevron_down, size: 12),
                  border: OutlineInputBorder(
                    borderRadius: isExpanded
                        ? const BorderRadius.vertical(top: Radius.circular(12))
                        : BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              isExpanded
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      decoration: BoxDecoration(
                        color:
                            widget.isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemCount: myCategoriesIcons.length,
                          itemBuilder: (context, int i) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  iconSelected = myCategoriesIcons[i];
                                  isExpanded = false;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: iconSelected == myCategoriesIcons[i]
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/${myCategoriesIcons[i]}.png',
                                    ),
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Container(),
              const SizedBox(height: 10),
              TextFormField(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: widget.isDarkMode
                            ? Colors.black
                            : const Color.fromARGB(255, 204, 211, 223),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorPicker(
                              pickerColor: categoryColor,
                              onColorChanged: (value) {
                                setState(() {
                                  categoryColor = value;
                                });
                              },
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 50,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Save'.tr,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                textAlignVertical: TextAlignVertical.center,
                readOnly: true,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: categoryColor,
                  hintText: "Color".tr,
                  hintStyle: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 50,
                    child: TextButton(
                      onPressed: () async {
                        if (_categoryController.text.isEmpty ||
                            iconSelected.isEmpty ||
                            categoryColor ==
                                (widget.isDarkMode
                                    ? Colors.black
                                    : Colors.white)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill in all fields.')),
                          );
                          return;
                        }

                        // Store the Color object directly in the map
                        final categoryData = {
                          'name': _categoryController.text,
                          'icon': iconSelected,
                          'color': categoryColor,
                          // Keep the color as a Color object
                        };

                        // Convert the Color to a string representation for database storage
                        String colorString =
                            categoryColor.value.toRadixString(16);

                        // Call the addCategory method from the controller
                        int? categoryId = await _authController.addCategory(
                          categoryName: categoryData['name'] as String,
                          categoryIcon: categoryData['icon'] as String,
                          categoryColor:
                              colorString, // Pass the color as a string
                        );
                        print(categoryColor);

                        if (categoryId != null) {
                          Navigator.of(context).pop(categoryData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Category added successfully.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to add category.')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF130F39),
                      ),
                      child: Text(
                        'Save'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 19),
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
