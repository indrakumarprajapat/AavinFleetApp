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
import '../modules/pdf/binding/pdf_binding.dart';
import '../modules/pdf/view/pdf_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/store_detail/view/store_details_view.dart';

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
      binding: DeliveryRouteBinding(),
    ),
    // GetPage(
    //   name: _Paths.DASHBOARD,
    //   page: () => const DashboardView(),
    //   binding: DashboardBinding(),
    // ),
    GetPage(
      name: _Paths.PDF,
      page: () => const PdfView(),
      binding: PdfBinding(),
    ),
  ];
}
