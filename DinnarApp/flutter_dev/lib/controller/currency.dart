import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/currency.dart';
import 'package:get_storage/get_storage.dart';
import '../constant/constant.dart';

class CurrencyController extends GetxController {
  var selectedCurrency = Rx<Currency>(Currency.currencies.first);
  final box = GetStorage();
  final exchangeRate = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserCurrency();
    fetchTransactionCurrency(); // Fetch transaction currency during initialization
  }

  // Change the currency and persist it
  void changeCurrency(Currency currency) {
    selectedCurrency.value = currency;
    updateUserCurrency(currency.code); // Update the currency on the server
    updateTransactionCurrency(
        currency.code); // Update the currency for transactions
    box.write('selectedCurrency', currency.code); // Persist currency code

    print('Currency changed to: ${currency.code}');
  }

  // Update the user currency on the server
  Future<void> updateUserCurrency(String currencyCode) async {
    try {
      final token = box.read('token'); // Read token from GetStorage
      final userId = box.read('user_id'); // Read user_id from GetStorage

      if (token == null || userId == null) {
        print('Token or user_id is missing');
        return;
      }

      final response = await http.post(
        Uri.parse(url + 'user/update-currency'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'currency': currencyCode}),
      );

      if (response.statusCode == 200) {
        print('Currency updated successfully');
      } else {
        print('Failed to update currency: ${response.body}');
      }
    } catch (e) {
      print('Error updating currency: $e');
    }
  }

  // Update the transaction currency on the server
  Future<void> updateTransactionCurrency(String currencyCode) async {
    try {
      final token = box.read('token'); // Read token from GetStorage

      if (token == null) {
        print('Token is missing');
        return;
      }

      final response = await http.post(
        Uri.parse(url + 'transactions/update-currency'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'currency': currencyCode}),
      );

      if (response.statusCode == 200) {
        print('Transaction currency updated successfully');
      } else {
        print('Failed to update transaction currency: ${response.body}');
      }
    } catch (e) {
      print('Error updating transaction currency: $e');
    }
  }

  // Fetch the user's currency from the server
  Future<void> fetchUserCurrency() async {
    try {
      final token = box.read('token'); // Read token from GetStorage

      if (token == null) {
        print('Token is missing');
        return;
      }

      final response = await http.get(
        Uri.parse(url + 'user/currency'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currencyCode = data['currency'];
        final currency = Currency.currencies.firstWhere(
          (curr) => curr.code == currencyCode,
          orElse: () => Currency.currencies.first,
        );
        changeCurrency(currency);
      } else {
        print('Failed to fetch user currency: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user currency: $e');
    }
  }

  // Fetch the transaction currency from the server
  Future<void> fetchTransactionCurrency() async {
    try {
      final token = box.read('token'); // Read token from GetStorage

      if (token == null) {
        print('Token is missing');
        return;
      }

      final response = await http.get(
        Uri.parse(url + 'transactions/currency'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currencyCode = data['currency'];
        final currency = Currency.currencies.firstWhere(
          (curr) => curr.code == currencyCode,
          orElse: () => Currency.currencies.first,
        );
        selectedCurrency.value = currency;
        print('Transaction currency fetched: ${currency.code}');
      } else {
        print('Failed to fetch transaction currency: ${response.body}');
      }
    } catch (e) {
      print('Error fetching transaction currency: $e');
    }
  }
}
