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
  List<TextEditingController> otpControllers = [];
  List<FocusNode> focusNodes = [];
  bool _obscurePassword = true;
  final config = Get.find<ClientConfig>();

  @override
  void initState() {
    super.initState();
    otpControllers = List.generate(4, (index) => TextEditingController());
    focusNodes = List.generate(4, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

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
                  child:
                      Column(
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
                  Text('&'),
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
        SvgPicture.asset(config.loginLogo
          ,
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
              maxLength: 20,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
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
            Obx(() => controller.isPasswordLogin ? Column(
              children: [
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
            ) : SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: 16),

        if (config.name != ClientConfig.CLIENT_NILGIRIS) ...[
          Obx(() => controller.isPasswordLogin ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: controller.forgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ): SizedBox.shrink()),
          const SizedBox(height: 8),
        ],

        Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (controller.isLoading) ? null : () {
              try {

                  if (!controller.isDisposed) {
                    if (controller.isPasswordLogin) {
                      controller.loginWithPassword();
                    } else {
                      controller.sendOtp();
                    }
                }
              } catch (e) {
                // Controller disposed
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              controller.isPasswordLogin ? 'Login' : 'Send OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )),

        // if (config.name != ClientConfig.CLIENT_NILGIRIS) ...[
        //   const SizedBox(height: 35),
          // Row(
          //   children: [
          //     Expanded(child: Divider(color: Colors.grey.shade300)),
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       child: Text(
          //         'OR',
          //         style: TextStyle(
          //           color: AppColors.textSecondary,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ),
          //     Expanded(child: Divider(color: Colors.grey.shade300)),
          //   ],
          // ),
          // const SizedBox(height: 35),
          // Obx(() => Container(
          //   width: double.infinity,
          //   height: 48,
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: AppColors.primary,
          //       width: 1.5,
          //     ),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: TextButton(
          //     onPressed: controller.toggleLoginMethod,
          //     style: TextButton.styleFrom(
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           controller.isPasswordLogin ? Icons.sms : Icons.lock,
          //           color: AppColors.primary,
          //           size: 20,
          //         ),
          //         const SizedBox(width: 8),
          //         Text(
          //           controller.isPasswordLogin ? 'Login with OTP' : 'Login with Password',
          //           style: TextStyle(
          //             color: AppColors.primary,
          //             fontSize: 16,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // )),
        // ],
      ],
    );
  }

  Widget _buildOtpSection(LoginController controller) {
    final phoneText = controller.phoneController.text;

    return Column(
      children: [
        Text(
          'OTP sent to registered Mobile Number',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        _buildOtpBoxes(controller),
        const SizedBox(height: 24),

        Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (controller.isLoading) ? null : () {
              try {

                  if (!controller.isDisposed) {
                    controller.verifyOtp();
                }
              } catch (e) {
                // Controller disposed
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: (controller.isLoading)
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () async {
            try {

                final response = await Get.find<ApiService>().agentResendOtp(controller.tempToken.value);
                Get.snackbar('Success', response['message']);
            } catch (e) {
              Get.snackbar('Error', e.toString());
            }
          },
          child: Text(
            'Resend OTP',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBoxes(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return Container(
          width: 45,
          height: 55,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 3) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }

              String otp = '';
              for (int i = 0; i < 4; i++) {
                otp += otpControllers[i].text;
              }

              try {

                  if (!controller.isDisposed) {
                    controller.otpController.text = otp;
                  }

                if (otp.length == 4) {
                  Future.delayed(Duration(milliseconds: 100), () {
                      controller.verifyOtp();

                  });
                }
              } catch (e) {
                // Controller disposed
              }
            },
          ),
        );
      }),
    );
  }
}