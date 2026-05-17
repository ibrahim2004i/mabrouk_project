import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/localization/locale_provider.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:get/get.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        title: Text(AppStrings.settings.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              Icons.language, 
              AppStrings.appLanguage.tr, 
              currentLocale.languageCode == 'ar' ? AppStrings.arabic.tr : AppStrings.english.tr,
              onTap: () => _showLanguagePicker(context, ref),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.notifications_active_outlined, 
              AppStrings.notifications.tr, 
              AppStrings.enabled.tr,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.security_outlined, 
              AppStrings.security.tr, 
              AppStrings.active.tr,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.help_outline, 
              AppStrings.helpCenter.tr, 
              '',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            _buildSettingsItem(
              context,
              Icons.info_outline, 
              AppStrings.aboutApp.tr, 
              '${AppStrings.version.tr} 1.0.0',
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.madeWithLove.tr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Text('MABROUK © 2024', style: TextStyle(fontWeight: FontWeight.bold, color: maroon.withOpacity(0.5), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String value, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.get3DShadows(),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentGold),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon),
              ),
            ),
            if (value.isNotEmpty) 
              Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.selectLanguage.tr,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon),
              ),
              const SizedBox(height: 24),
              _languageOption(
                context, 
                AppStrings.arabic.tr, 
                ref.read(localeProvider).languageCode == 'ar',
                () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
                  Navigator.pop(context);
                }
              ),
              const SizedBox(height: 12),
              _languageOption(
                context, 
                AppStrings.english.tr, 
                ref.read(localeProvider).languageCode == 'en',
                () {
                  ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                  Navigator.pop(context);
                }
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMaroon.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppTheme.primaryMaroon : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryMaroon : Colors.black87)),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryMaroon),
          ],
        ),
      ),
    );
  }
}
