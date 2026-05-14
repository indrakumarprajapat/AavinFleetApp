import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_enums.dart';
import '../models/models.dart';
import '../models/fleet_user.dart';

class SessionManager extends GetxService {
  final _storage = GetStorage();

  /// 🔑 Keys (centralized)
  static const _kAccessToken = 'access_token';
  static const _kUserType = 'user_type';
  static const _kFleetUser = 'fleetUser';

  /// 🔥 In-memory reactive user
  final Rxn<FleetUser> fleetUser = Rxn<FleetUser>();

  String? get accessToken => _storage.read(_kAccessToken);

  int? get userType => _storage.read(_kUserType);

  /// 🔹 Save full session
  Future<void> saveSession(FleetUser? user) async {
    if (user == null) return;

    fleetUser.value = user;
    print('--Save--');
    print(user.accessToken);
    await _storage.write(_kAccessToken, user.accessToken);
    await _storage.write(_kUserType, UserType.fleetUser.index);
    await _storage.write(_kFleetUser, user.toJson()); // ✅ JSON only
  }

  /// 🔹 Load from storage (app start)
  void loadSession() {
    final data = _storage.read(_kFleetUser);

    if (data != null && data is Map) {
      fleetUser.value = FleetUser.fromJson(
        Map<String, dynamic>.from(data),
      );
    }
  }

  /// 🔹 Clear session (logout)
  Future<void> clearSession() async {
    fleetUser.value = null;
    await _storage.erase();
  }
}