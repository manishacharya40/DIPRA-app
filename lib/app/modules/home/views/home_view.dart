import 'package:dipra_app/app/utils/validator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  final loginFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomeView'), centerTitle: true),
      body: MaterialButton(
        onPressed: () {
          Get.toNamed('/dipra');
        },
        child: Text("DIPRA"),
      ),
    );
  }
}
