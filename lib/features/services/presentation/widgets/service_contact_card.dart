import 'package:flutter/material.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/service_models.dart';

class ServiceContactCard extends StatelessWidget {
  final ServiceBase service;
  const ServiceContactCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: maroon.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
  children: [
    _contactActionBtn(
      Icons.message_rounded,
      maroon,
      AppStrings.chat.tr,
      onTap: () => _launchWhatsApp(context, service.whatsappNumber),
    ),

    const SizedBox(width: 10),

    _contactActionBtn(
      Icons.phone_rounded,
      maroon,
      AppStrings.call.tr,
      onTap: () => _launchCaller(context, service.phoneNumber),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            service.brandName ?? AppStrings.certifiedProvider.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: maroon,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: maroon.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.locationAddress ??
                  service.cityName ??
                  AppStrings.defaultLocation.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: maroon.withOpacity(0.65),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),
    );
  }

  Widget _contactActionBtn(
    IconData icon,
    Color color,
    String label, {
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 58,
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _launchWhatsApp(BuildContext context, String? number) async {
    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.whatsappNotAvailable.tr)),
      );
      return;
    }

    String cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanNumber.startsWith('0')) {
      cleanNumber = '962${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('962')) {
      cleanNumber = '962$cleanNumber';
    }

    final url = Uri.parse("https://wa.me/$cleanNumber");

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.cannotOpenWhatsapp.tr)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.error.tr}: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _launchCaller(BuildContext context, String? number) async {
    if (number == null || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.callNotAvailable.tr)),
      );
      return;
    }

    final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse("tel:$cleanNumber");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.cannotOpenDialer.tr)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.error.tr}: ${e.toString()}')),
        );
      }
    }
  }
}