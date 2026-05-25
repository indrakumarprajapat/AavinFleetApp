import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_enums.dart';
import '../../../api/api_service.dart';
import '../controllers/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;
  final config = Get.find<ClientConfig>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final userType = UserType.fleetUser;
    controller.setUserType(userType);
    return _buildScaffold(context, controller);
  }

  Widget _buildScaffold(BuildContext context, LoginController controller) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildHeader(),
                      const SizedBox(height: 60),
                      _buildPhoneSection(controller)
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(config.privacyPolicyLink));
                    },
                    child: const Text(
                      "Privacy Policy",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  const Text('&'),
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(config.termAndCondLink));
                    },
                    child: const Text(
                      "Term & Conditions",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SvgPicture.asset(
          config.loginLogo,
          width: 80,
          height: 80,
        ),
        const SizedBox(height: 24),
        Text(
          'Fleet Login',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(LoginController controller) {
    final phoneController = controller.phoneController;

    return Column(
      children: [
        Column(
          children: [
            TextField(
              controller: phoneController,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: 'Enter Route ID or Username',
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Enter Password',
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 64),
        Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (controller.isLoading)
                    ? null
                    : () {
                        controller.loginWithPassword();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )),
      ],
    );
  }
}
