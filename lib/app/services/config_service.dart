import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_service.dart';
import '../constants/app_enums.dart';

class ConfigService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();
  
  final config = Rxn<Map<String, dynamic>>();
  
  // Config getters
  String get googleMapsApiKey => config.value?['google_maps_api_key'] ?? '';
  String get privacyPolicyUrl => config.value?['privacy_policy_url'] ?? '';
  String get paymentResponseUrl => config.value?['payment_response_url'] ?? '';
  
  double get defaultLatitude => config.value?['default_location']?['latitude'] ?? 11.0168;
  double get defaultLongitude => config.value?['default_location']?['longitude'] ?? 76.9558;
  String get defaultCity => config.value?['default_location']?['city'] ?? 'Coimbatore';
  
  int get connectTimeout => config.value?['api_settings']?['connect_timeout'] ?? 30;
  int get receiveTimeout => config.value?['api_settings']?['receive_timeout'] ?? 30;
  int get maxRetries => config.value?['api_settings']?['max_retries'] ?? 3;
  
  String get countryRestriction => config.value?['map_settings']?['country_restriction'] ?? 'in';
  int get searchRadius => config.value?['map_settings']?['search_radius'] ?? 500000;
  late final userType = _storage.read('user_type') ?? UserType.fleetUser.index;
  @override
  void onInit() {
    super.onInit();
    loadCachedConfig();
  }
  
  @override
  void onReady() {
    super.onReady();
    fetchConfig();
  }

  @override
  void onClose() {
    config.value = null;
    super.onClose();
  }
  
  void loadCachedConfig() {
    final cachedConfig = _storage.read('app_config');
    if (cachedConfig != null) {
      config.value = Map<String, dynamic>.from(cachedConfig);
    } else {
      print('ConfigService: No cached config found');
    }
  }
  
  Future<void> fetchConfig() async {
    try {
      final response = await _apiService.getAppConfig(userType: userType);
      if (response['success'] == true) {
        config.value = response['config'];
        await _storage.write('app_config', response['config']);
      } else {
        print('ConfigService: API response success = false');
      }
    } catch (e) {
      print('ConfigService: Failed to fetch config: $e');
    }
  }
}