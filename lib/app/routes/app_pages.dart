import 'package:get/get.dart';

import '../modules/agent/home/bindings/home_binding.dart';
import '../modules/dashboard/binding/dashboard_binding.dart';
import '../modules/dashboard/view/dashboard_view.dart';
import '../modules/delivery/binding/delivery_binding.dart';
import '../modules/delivery/view/delivery_route_view.dart';
// import '../modules/home/binding/home_binding.dart';
// import '../modules/home/view/home_view.dart';
import '../modules/agent/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/store_detail/binding/store_details_binding.dart';
import '../modules/store_detail/view/store_details_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/agent/profile/views/agent_profile_view.dart';
import '../modules/agent/change_password/bindings/change_password_binding.dart';
import '../modules/agent/change_password/views/change_password_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;
  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () =>   HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_ROUTE,
      page: () => const DeliveryRouteView(),
      binding: DeliveryRouteBinding(),
    ),
    GetPage(
      name: _Paths.STORE_DETAILS,
      page: () => const StoreDetailsView(),
      binding: StoreDetailsBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const AgentProfileView(),
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
  ];
}
