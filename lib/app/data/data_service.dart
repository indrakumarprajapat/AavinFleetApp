import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/agent_model.dart';
import '../models/customer_model.dart';

class DataService extends GetxService {
  static DataService get to => Get.find<DataService>();

  late GetStorage _box;

  // STORAGE KEYS
  final String _kAccessToken = 'access_token';
  final String _kCustomerModel = 'customer_model';
  final String _kAgentModel = 'agent_model';
  final String _kUserType = 'user_type';

  Future<DataService> init() async {
    _box = GetStorage();
    return this;
  }

  Future<void> saveAccessToken(String token) async {
    await _box.write(_kAccessToken, token);
  }

  String? get accessToken => _box.read(_kAccessToken);

  Future<void> clearAccessToken() async {
    await _box.remove(_kAccessToken);
  }

  Future<void> saveUserType(String type) async {
    await _box.write(_kUserType, type);
  }

  String? get userType => _box.read(_kUserType);

  Future<void> clearUserType() async {
    await _box.remove(_kUserType);
  }

  Future<void> saveCustomerModel(Customer user) async {
    await _box.write(_kCustomerModel, user.toJson());
  }

  Customer? get customerModel {
    final data = _box.read(_kCustomerModel);
    return data != null ? Customer.fromJson(data) : null;
  }

  Future<void> clearCustomerModel() async {
    await _box.remove(_kCustomerModel);
  }
  Future<void> saveAgentModel(SocietyUser user) async {
    await _box.write(_kAgentModel, user.toJson());
  }

  SocietyUser? get agentModel {
    final data = _box.read(_kAgentModel);
    return data != null ? SocietyUser.fromJson(data) : null;
  }

  Future<void> clearAgentModel() async {
    await _box.remove(_kAgentModel);
  }


  Future<void> clearAll() async {
    await _box.erase();
  }
}
