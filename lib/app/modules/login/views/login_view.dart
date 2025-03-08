import 'package:dipra_app/app/utils/validator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  final loginFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoginView'), centerTitle: true),
      // body: MaterialButton(
      //   onPressed: () {
      //     Get.toNamed('/dipra');
      //   },
      //   child: Text("DIPRA"),
      // ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTopSection(context),
            _buildFormSection(context, loginFormKey),
          ],
        ),
      ),
    );
  }
}

_buildTopSection(BuildContext context) {
  return SizedBox(
    height: Get.size.height * 0.3,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sign in to \nAccount",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Sign in to your account",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

_buildFormSection(BuildContext context, GlobalKey<FormState> loginFormKey) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _buildLoginForm(context, loginFormKey),
      ),
    ),
  );
}

_buildLoginForm(BuildContext context, GlobalKey<FormState> loginFormKey) {
  return Form(
    key: loginFormKey,
    child: Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: "your-mail@email.com",
            filled: true,
            fillColor: Colors.blue,
            prefixIcon: const Icon(Icons.email),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: Validators.emailValidator, // Moved outside the decoration
          controller:
              Get.find<LoginController>()
                  .emailController, // Moved outside the decoration
        ),
        Obx(() {
          return TextFormField(
            obscureText: !Get.find<LoginController>().isPasswordVisible.value,
            decoration: InputDecoration(
              hintText: "Password",
              filled: true,
              fillColor: Colors.green,
              prefixIcon: const Icon(Icons.lock),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  Get.find<LoginController>().isPasswordVisible.toggle();
                },
                icon: Icon(
                  Get.find<LoginController>().isPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),
            validator:
                Validators.passwordValidator, // ✅ Move outside `decoration`
            controller:
                Get.find<LoginController>()
                    .passwordController, // ✅ Move outside `decoration`
          );
        }),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () {}, child: Text("Forgot Password?")),
        ),
        ElevatedButton(
          onPressed: () {
            if (loginFormKey.currentState!.validate()) {
              Get.find<LoginController>().loginUser();
            }
          },
          child: const Text("Sign In"),
        ),
        Obx(() {
          return Get.find<LoginController>().isLoading.value
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(); // Hide if not loading
        }),
      ],
    ),
  );
}
