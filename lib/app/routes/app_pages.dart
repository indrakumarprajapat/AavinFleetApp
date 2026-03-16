import 'package:get/get.dart';

import '../modules/add_funds/bindings/add_funds_binding.dart';
import '../modules/add_funds/views/add_funds_view.dart';
import '../modules/agent/booth_capture/bindings/booth_capture_binding.dart';
import '../modules/agent/booth_capture/views/booth_capture_view.dart';
import '../modules/agent/cart/views/cart_view.dart';
import '../modules/agent/change_password/bindings/change_password_binding.dart';
import '../modules/agent/change_password/views/change_password_view.dart';
import '../modules/agent/checkout/bindings/checkout_binding.dart';
import '../modules/agent/checkout/views/checkout_view.dart';
import '../modules/agent/claims/controllers/claims_controller.dart';
import '../modules/agent/claims/views/claim_details_view.dart';
import '../modules/agent/claims/views/claims_view.dart';
import '../modules/agent/claims/views/create_claim_view.dart';
import '../modules/agent/commission/bindings/commission_statement_binding.dart';
import '../modules/agent/commission/views/commission_statement_view.dart';
import '../modules/agent/earnings/bindings/earnings_binding.dart';
import '../modules/agent/earnings/views/earnings_view.dart';
import '../modules/agent/home/bindings/home_binding.dart';
import '../modules/agent/home/views/home_view.dart';
import '../modules/agent/monthly-statements/bindings/monthly_statement_binding.dart';
import '../modules/agent/monthly-statements/views/monthly_statement_view.dart';
import '../modules/agent/order/bindings/order_binding.dart';
import '../modules/agent/order/views/order_view.dart';
import '../modules/agent/order_details/bindings/order_details_binding.dart';
import '../modules/agent/order_details/views/order_details_view.dart';
import '../modules/agent/product_selection/views/product_selection_view.dart';
import '../modules/easypay_webview/controllers/easypay_webview_controller.dart';
import '../modules/easypay_webview/views/easypay_webview_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/map_picker/bindings/map_picker_binding.dart';
import '../modules/map_picker/views/map_picker_view.dart';
import '../modules/milk_supplies/views/milk_supplies_list_view.dart';
import '../modules/milk_supplies/views/milk_supply_details_view.dart';
import '../modules/order_success/views/order_success_view.dart';
import '../modules/reset_password/views/reset_password_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/user_type/bindings/user_type_binding.dart';
import '../modules/user_type/views/user_type_view.dart';

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
      name: _Paths.USER_TYPE,
      page: () => const UserTypeView(),
      binding: UserTypeBinding(),
      transitionDuration: Duration(milliseconds: 1500),
      transition: Transition.fade,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ORDER,
      page: () => const OrderView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: '/product-selection',
      page: () => const ProductSelectionView(),
    ),
    GetPage(
      name: _Paths.ADD_FUNDS,
      page: () => const AddFundsView(),
      binding: AddFundsBinding(),
    ),
    GetPage(
      name: _Paths.BOOTH_CAPTURE,
      page: () => const BoothCaptureView(),
      binding: BoothCaptureBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
    ),
    GetPage(
      name: '/checkout',
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: '/order-success',
      page: () => const OrderSuccessView(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAILS,
      page: () => const OrderDetailsView(),
      binding: OrderDetailsBinding(),
    ),
    GetPage(
      name: _Paths.EASYPAY_WEBVIEW,
      page: () => const EasyPayWebviewView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EasyPayWebviewController>(() => EasyPayWebviewController());
      }),
    ),
    GetPage(
      name: _Paths.CLAIMS,
      page: () => const ClaimsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClaimsController>(() => ClaimsController());
      }),
    ),
    GetPage(
      name: _Paths.CREATE_CLAIM,
      page: () => const CreateClaimView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClaimsController>(() => ClaimsController());
      }),
    ),
    GetPage(
      name: _Paths.CLAIM_DETAILS,
      page: () => const ClaimDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClaimsController>(() => ClaimsController());
      }),
    ),
    GetPage(
      name: _Paths.ADD_ADDRESS_MAP,
      page: () => const MapPickerView(),
      binding: MapPickerBinding(),
    ),
    GetPage(
      name: _Paths.COMMISSION_STATEMENT,
      page: () => const CommissionStatementView(),
      binding: CommissionStatementBinding(),
    ),
    GetPage(
      name: _Paths.MONTHLY_STATEMENTS,
      page: () => const MonthlyStatementView(),
      binding: MonthlyStatementBinding(),
    ),
    GetPage(
      name: '/earnings',
      page: () => const EarningsView(),
      binding: EarningsBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: '/reset-password',
      page: () => ResetPasswordView(),
    ),
    GetPage(
      name: '/milk-supplies',
      page: () => MilkSuppliesListView(),
    ),
    GetPage(
      name: '/milk-supplies/:id',
      page: () => MilkSupplyDetailsView(),
    ),
  ];
}
