import 'package:get/get.dart';
import 'app_config.dart';

class AppInitializer {
  static void init() {
    const client = String.fromEnvironment(
      'CLIENT',
      defaultValue: ClientConfig.CLIENT_DEFAULT,
    );
    final config = clientConfigs[client] ?? clientConfigs[ClientConfig.CLIENT_DEFAULT]!;
    Get.put<ClientConfig>(config, permanent: true);
  }
}
