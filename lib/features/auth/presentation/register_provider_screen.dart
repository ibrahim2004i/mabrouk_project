import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../services/data/reference_repository.dart';
import 'auth_state.dart';

class RegisterProviderScreen extends ConsumerStatefulWidget {
  const RegisterProviderScreen({super.key});

  @override
  ConsumerState<RegisterProviderScreen> createState() => _RegisterProviderScreenState();
}

class _RegisterProviderScreenState extends ConsumerState<RegisterProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedCityId;

  @override
  void dispose() {
    _brandController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCityId == null) {
      if (_selectedCityId == null) {
        Get.snackbar(
          AppStrings.error.tr,
          AppStrings.pleaseSelectCity.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
      return;
    }

    await ref.read(authStateProvider.notifier).registerProvider(
      phone: _phoneController.text,
      password: _passwordController.text,
      brandName: _brandController.text,
      cityId: _selectedCityId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;
    final state = ref.watch(authStateProvider);
    final citiesAsync = ref.watch(citiesProvider);

    // Listen for state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthInitial && previous is AuthLoading) {
        // Successful registration but needs approval
        context.go('/register/pending-approval');
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
                const SizedBox(height: 10),
                Text(
                  AppStrings.amProvider.tr,
                  style: GoogleFonts.libreBaskerville(
                    color: maroon,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.providerSubtitle.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 35),
                
                _buildInput(
                  _brandController, 
                  AppStrings.shopOrCompanyName.tr, 
                  Icons.storefront_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.fieldRequired.tr;
                    if (v.trim().length < 3) return AppStrings.invalidName.tr;
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildInput(
                  _phoneController, 
                  AppStrings.contactPhoneNumber.tr, 
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
                
                const SizedBox(height: 15),
                // City Dropdown
                citiesAsync.when(
                  data: (cities) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: maroon.withOpacity(0.05), blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCityId,
                        hint: Text(AppStrings.selectCity.tr),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.location_city_rounded, color: Colors.grey),
                        ),
                        items: cities.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(Get.locale?.languageCode == 'en' ? (c.nameEn ?? c.nameAr) : c.nameAr),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedCityId = val),
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: maroon)),
                  error: (_, __) => Text(AppStrings.loadCitiesFailed.tr),
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
                      child: Text(AppStrings.submitJoinRequest.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                   AppStrings.approvalNote.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
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
