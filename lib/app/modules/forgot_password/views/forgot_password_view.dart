import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isOtpSent.value
                    ? 'Reset Your Password'
                    : 'Forgot Your Password?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                controller.isOtpSent.value
                    ? 'Enter the OTP sent to your mobile and your new password.'
                    : 'Enter your registered mobile number to receive an OTP.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              if (!controller.isOtpSent.value) ...[
                _buildTextField(
                  label: 'Mobile Number',
                  controller: controller.mobileController,
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                _buildTextField(
                  label: 'Enter OTP',
                  controller: controller.otpController,
                  icon: Icons.lock_clock_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'New Password',
                  controller: controller.newPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  isObscured: controller.obscureNewPassword.value,
                  onToggleVisibility: () => controller.obscureNewPassword.toggle(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Confirm New Password',
                  controller: controller.confirmPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  isObscured: controller.obscureConfirmPassword.value,
                  onToggleVisibility: () => controller.obscureConfirmPassword.toggle(),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (controller.isOtpSent.value) {
                            controller.resetPassword();
                          } else {
                            controller.sendOtp();
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
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.isOtpSent.value ? 'Reset Password' : 'Send OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (controller.isOtpSent.value) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => controller.isOtpSent.value = false,
                    child: const Text('Change Details'),
                  ),
                ),
              ],
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    bool isObscured = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText ? isObscured : false,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: obscureText
                ? IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
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
          ),
        ),
      ],
    );
  }
}
