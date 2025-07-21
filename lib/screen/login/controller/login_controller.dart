import 'dart:convert';

import 'package:dicabs/ALLURL.dart';
import 'package:dicabs/SharedPreference.dart';
import 'package:dicabs/core/show_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dicabs/validator/validator.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final userCodeController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;
  var isButtonEnabled = false.obs;
  String? userCodeError;
  String? passwordError;

  @override
  void onClose() {
    userCodeController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void validateForm() {
    userCodeError = validateUserCode(userCodeController.text);
    passwordError = validatePassword(passwordController.text);
    isButtonEnabled.value = (userCodeError == null && passwordError == null);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<bool> loginUser() async {
    final userCode = userCodeController.text.trim();
    final password = passwordController.text.trim();

    final url = Uri.parse(
      '$baseUrl/GetUserDetail?userCode=$userCode&password=$password',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      // Check if login is truly successful
      final isSuccess = jsonBody['Completed'] == true;

      if (isSuccess) {
        showLog(msg: "Login Success: ${jsonBody['Message']}");

        StorageManager.saveData('userCode', userCode);

        final salesCode = jsonBody['Data']?['Code'];
        if (salesCode != null) {
          StorageManager.saveData('salesCode', salesCode);
        }
        return true;
      } else {
        showLog(msg: "Login Failed: ${jsonBody['Message']}");
        return false;
      }
    } else {
      showLog(msg: "Login Failed: ${response.reasonPhrase}");
      return false;
    }
  }
}
