import 'package:get/get.dart';

import '../modules/dipra/bindings/dipra_binding.dart';
import '../modules/dipra/views/dipra_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.DIPRA,
      page: () => DipraView(),
      binding: DipraBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
