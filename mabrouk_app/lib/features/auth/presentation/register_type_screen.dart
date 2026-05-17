import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';

class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                AppStrings.joinUs.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.libreBaskerville(
                  color: maroon,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.chooseAccountType.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 50),
              _buildTypeCard(
                context,
                title: AppStrings.amCustomer.tr,
                subtitle: AppStrings.customerSubtitle.tr,
                icon: Icons.person_search_rounded,
                onTap: () => context.push('/register/customer'),
              ),
              const SizedBox(height: 25),
              _buildTypeCard(
                context,
                title: AppStrings.amProvider.tr,
                subtitle: AppStrings.providerSubtitle.tr,
                icon: Icons.store_mall_directory_rounded,
                onTap: () => context.push('/register/provider'),
              ),
              const Spacer(),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const maroon = AppTheme.primaryMaroon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: maroon.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: maroon.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: maroon, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: maroon,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
