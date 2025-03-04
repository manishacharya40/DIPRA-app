import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DipraController extends GetxController {
  final RxInt pipeSize = 3.obs;
  final RxString trenchType = 'Type 1'.obs;
  final workingpressureController = TextEditingController();
  final surgeallowanceController = TextEditingController();
  final depthofcoverController = TextEditingController();

  RxBool isPasswordVisible = false.obs;
}
