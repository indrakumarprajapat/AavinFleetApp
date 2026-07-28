part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const USER_TYPE = _Paths.USER_TYPE;
   static const LOGIN = _Paths.LOGIN;
   static const HOME = _Paths.HOME;
   static const DELIVERY_ROUTE = _Paths.DELIVERY_ROUTE;
   static const STORE_DETAILS = _Paths.STORE_DETAILS;
  static const COLLECTION_ROUTE = _Paths.COLLECTION_ROUTE;
  static const COLLECTION_STOP = _Paths.COLLECTION_STOP;
  static const COLLECTION_SUBMIT = _Paths.COLLECTION_SUBMIT;
  static const BOOTH_CAPTURE = _Paths.BOOTH_CAPTURE;
  static const EASYPAY_WEBVIEW = _Paths.EASYPAY_WEBVIEW;
  static const CHANGE_PASSWORD = _Paths.CHANGE_PASSWORD;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const PROFILE = _Paths.PROFILE;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home-view';
  static const DELIVERY_ROUTE = '/delivery-routes';
  static const STORE_DETAILS = '/store-details-view';
  static const COLLECTION_ROUTE = '/collection-route';
  static const COLLECTION_STOP = '/collection-stop';
  static const COLLECTION_SUBMIT = '/collection-submit';
  static const USER_TYPE = '/user-type';
  static const BOOTH_CAPTURE = '/booth-capture';
  static const EASYPAY_WEBVIEW = '/easypay-webview';
  static const CHANGE_PASSWORD = '/change-password';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const PROFILE = '/profile';
}
