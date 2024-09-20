import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/user.dart';
import '../constant/constant.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  var user = UserModel(id: 0, name: '', email: '', phone: '').obs;
  var isLoading = true.obs;
  final box = GetStorage();

  @override
  void onInit() {
    fetchUser();
    super.onInit();
  }

  void fetchUser() async {
    isLoading(true);
    try {
      final token = box.read('token');
      var response = await http.get(
        Uri.parse(url + 'user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        user.value = UserModel.fromJson(data);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<http.Response?> updateUser(
      String name, String email, String phone) async {
    final token = box.read('token'); // Read token here
    if (token == null) {
      Get.snackbar('Error', 'Authentication token not found');
      return null;
    }

    final Url =
        Uri.parse(url + 'update-user'); // Ensure baseUrl is defined correctly

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'name': name,
      'email': email,
      'phone': phone,
    });

    try {
      final response = await http.put(Url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Optionally update local user data
        var data = json.decode(response.body);
        user.value = UserModel.fromJson(
            data['user']); // Adjust based on your API response
        return response;
      } else {
        final responseBody = json.decode(response.body);
        Get.snackbar('Error', responseBody['error'] ?? 'Failed to update user');
        print('Failed to update user: ${responseBody}');
        return response;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while updating profile');
      print('Error updating user: $e');
      return null;
    }
  }
}
