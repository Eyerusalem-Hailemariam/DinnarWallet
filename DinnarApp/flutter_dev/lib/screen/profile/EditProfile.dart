import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dev/controller/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final UserController userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();
  final box = GetStorage();
  late String initialEmail;
  String updatedEmail = '';
  String name = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    initialEmail = userController.user.value.email;
    name = userController.user.value.name;
    phone = userController.user.value.phone;
  }

  
  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

    
      var response = await userController.updateUser(name, initialEmail, phone);

      if (response != null && response.statusCode == 200) {
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
      
        Get.snackbar('Error', 'Failed to update profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 40),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 4, color: Colors.white),
                boxShadow: [
                  BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.1))
                ]),
            child: Icon((CupertinoIcons.person)),
          ),
          SizedBox(
            height: 15,
          ),
          Obx(() {
            if (userController.isLoading.value) {
              return Text('Loading...');
            } else {
              return Text(userController.user.value.email.isNotEmpty
                  ? userController.user.value.email
                  : 'No Email');
            }
          }),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      icon: Icon(CupertinoIcons.person),
                      labelText: "Name",
                    ),
                    onSaved: (value) => name = value!.trim(),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                      initialValue: phone,
                      decoration: const InputDecoration(
                        icon: Icon(CupertinoIcons.phone),
                        labelText: "Phone Number",
                      ),
                      onSaved: (value) => phone = value!.trim(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10 digit phone number';
                        }
                      }),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _updateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF130F39),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Update Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
