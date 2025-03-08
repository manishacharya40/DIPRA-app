import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isPasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  Future<void> loginUser() async {
    isLoading.value = true;
    try {
      bool success = await fakeLogin(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        isLoading.value = false;
        Get.offNamed('/dipra');
        emailController.clear();
        passwordController.clear();
      } else {
        isLoading.value = false;
        Get.snackbar(
          "Login Failed",
          "Incorrect email or password.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Login Error",
        "An error occurred during login. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Login error: $e");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> fakeLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == "manish@isu.com" && password == "Password123") {
      return true;
    } else {
      return false;
    }
  }
}
