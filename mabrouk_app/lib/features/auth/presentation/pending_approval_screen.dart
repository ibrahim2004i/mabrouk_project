import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: maroon.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_as_unread_rounded, color: maroon, size: 80),
              ),
              const SizedBox(height: 40),
              Text(
                AppStrings.pendingApprovalTitle.tr,
                style: GoogleFonts.libreBaskerville(
                  color: maroon,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.pendingApprovalMessage.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(AppStrings.loginButton.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
