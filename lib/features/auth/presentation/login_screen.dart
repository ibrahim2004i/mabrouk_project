import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import 'auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authStateProvider.notifier).login(
        _phoneController.text.trim(), 
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    // Derived error message for display
    String? displayErrorMessage;
    if (state is AuthError) {
      String lowercaseMsg = state.message.toLowerCase();
      if (lowercaseMsg.contains('401') || 
          lowercaseMsg.contains('invalid') || 
          lowercaseMsg.contains('unauthorized') ||
          lowercaseMsg.contains('credentials')) {
        displayErrorMessage = AppStrings.wrongPhoneOrPassword.tr;
      } else if (lowercaseMsg.contains('403') || 
                 lowercaseMsg.contains('مراجعة') || 
                 lowercaseMsg.contains('فعيله') ||
                 lowercaseMsg.contains('pending')) {
        displayErrorMessage = AppStrings.pendingApprovalLogin.tr;
      } else {
        displayErrorMessage = state.message;
      }
    }

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 70),
                
                Text(
                  AppStrings.appName.tr,
                  style: GoogleFonts.libreBaskerville(
                    color: maroon,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(offset: const Offset(1.5, 1.5), color: Colors.black.withOpacity(0.3)),
                      Shadow(offset: const Offset(3.0, 3.0), color: Colors.black.withOpacity(0.2)),
                      Shadow(offset: const Offset(4.5, 4.5), color: Colors.black.withOpacity(0.1), blurRadius: 5),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                Text(
                  AppStrings.loginTitle.tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: maroon.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 30),
              
                _buildInput(
                  _phoneController, 
                  AppStrings.phoneNumber.tr, 
                  Icons.phone_android_outlined, 
                  isPhone: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.fieldRequired.tr;
                    if (v.length < 10) return AppStrings.invalidPhoneNumber.tr;
                    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return AppStrings.numericOnlyError.tr;
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildInput(
                  _passwordController, 
                  AppStrings.password.tr, 
                  Icons.lock_outline, 
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.fieldRequired.tr;
                    if (v.length < 6) return AppStrings.passwordTooShort.tr;
                    return null;
                  },
                ),
              
                const SizedBox(height: 10),
              
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // Placeholder for future functionality
                    },
                    child: Text(
                      AppStrings.forgotPassword.tr, 
                      style: TextStyle(color: maroon.withOpacity(0.7)),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 🚨 DIRECT ERROR MESSAGE DISPLAY
                if (displayErrorMessage != null)
                   Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayErrorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                if (state is AuthLoading)
                  const Center(child: CircularProgressIndicator(color: maroon))
                else
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: maroon.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        onPressed: _onLogin,
                        child: Text(
                          AppStrings.loginButton.tr,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        side: BorderSide(color: maroon.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => context.go('/customer/home'),
                      child: Text(
                        AppStrings.discoverAppFirst.tr,
                        style: const TextStyle(color: maroon, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount.tr),
                    TextButton(
                      onPressed: () => context.push('/register-type'),
                      child: Text(
                        AppStrings.createNewAccount.tr,
                        style: const TextStyle(color: maroon, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {bool isPassword = false, bool isPhone = false, String? Function(String?)? validator}
  ) {
    const maroon = AppTheme.primaryMaroon;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        textAlign: TextAlign.right,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: maroon, size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: maroon.withOpacity(0.5)),
          ),
          errorStyle: const TextStyle(height: 0.8),
        ),
      ),
    );
  }
}
