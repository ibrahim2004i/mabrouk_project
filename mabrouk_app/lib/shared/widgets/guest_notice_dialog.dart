import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

import 'package:mabrouk_app/core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

class GuestNoticeDialog extends StatelessWidget {
  const GuestNoticeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  beige,
                  beige.withOpacity(0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: maroon.withOpacity(0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: maroon.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ICON
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        maroon.withOpacity(0.12),
                        maroon.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: maroon.withOpacity(0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: maroon,
                    size: 44,
                  ),
                ),

                const SizedBox(height: 22),

                // TITLE
                Text(
                  AppStrings.membersOnlyFeature.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: maroon,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // DESCRIPTION
                Text(
                  AppStrings.exploreMabroukFullExperience.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.75),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 30),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      AppStrings.loginNowButton.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // CONTINUE AS GUEST
                TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: maroon.withOpacity(0.7),
                  ),
                  child: Text(
                    AppStrings.continueAsGuest.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) => const GuestNoticeDialog(),
    );
  }
}