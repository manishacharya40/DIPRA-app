import 'package:get/get.dart';

import '../controllers/dipra_controller.dart';

class DipraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DipraController>(
      () => DipraController(),
    );
  }
}
