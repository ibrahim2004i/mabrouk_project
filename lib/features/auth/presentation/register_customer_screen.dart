import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import 'auth_state.dart';

class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  ConsumerState<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends ConsumerState<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authStateProvider.notifier).registerCustomer(
      phone: _phoneController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );
    // Success handling: login will be called automatically in the notifier,
    // and if authState becomes AuthSuccess, we navigate via router or listener.
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;
    final state = ref.watch(authStateProvider);

    // Listen for state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthSuccess) {
        context.go('/customer/home');
      } else if (next is AuthError) {
        Get.snackbar(
          AppStrings.error.tr,
          next.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 15,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    });

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: maroon),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  AppStrings.newCustomerAccount.tr,
                  style: GoogleFonts.libreBaskerville(
                    color: maroon,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.joinMabroukCommunity.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 40),
                
                _buildInput(
                  _nameController, 
                  AppStrings.fullName.tr, 
                  Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.fieldRequired.tr;
                    if (v.trim().length < 3) return AppStrings.invalidName.tr;
                    return null;
                  },
                ),
                const SizedBox(height: 15),
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
                
                const SizedBox(height: 40),
                
                if (state is AuthLoading)
                  const CircularProgressIndicator(color: maroon)
                else
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: Text(AppStrings.createAccountAndStart.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount.tr),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        AppStrings.loginNow.tr,
                        style: const TextStyle(color: maroon, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    {bool isPhone = false, bool isPassword = false, String? Function(String?)? validator}
  ) {
    const maroon = AppTheme.primaryMaroon;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      textAlign: TextAlign.right,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: maroon.withOpacity(0.4), fontSize: 14),
        prefixIcon: Icon(icon, color: maroon.withOpacity(0.6), size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: maroon.withOpacity(0.05), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: maroon.withOpacity(0.2), width: 1.5),
        ),
        errorStyle: const TextStyle(height: 0.8),
      ),
    );
  }
}

