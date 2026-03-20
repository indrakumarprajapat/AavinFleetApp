import 'package:get/get.dart';

import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();
  static String get baseUrl =>
      Get.find<ClientConfig>().baseUrl;
  static const String apiSocietyPrefix = 'sapi';
  static const int connectTimeout = 60;
  static const int receiveTimeout = 60;
  static const int maxRetries = 3;
}
