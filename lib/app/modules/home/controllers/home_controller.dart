import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isPasswordVisible = false.obs;

  loginUser() async {}
}
