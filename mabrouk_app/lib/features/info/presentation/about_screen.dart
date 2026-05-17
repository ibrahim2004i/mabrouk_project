import 'package:flutter/material.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:get/get.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const gold = AppTheme.accentGold;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        title: Text(AppStrings.whatIsMabrouk.tr, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: maroon,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.celebration, size: 80, color: gold),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.mabroukApp.tr,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: maroon),
                  ),
                  Text(AppStrings.platformOneForAll.tr, 
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle(AppStrings.whatIsMabrouk.tr, maroon),
            _buildContentText(AppStrings.whatIsMabroukDescription.tr),

            const SizedBox(height: 25),

            _buildSectionTitle(AppStrings.ourMainServices.tr, maroon),
            _buildServiceItem(Icons.cake, AppStrings.cakes.tr, AppStrings.mainServicesCakeDesc.tr, gold),
            _buildServiceItem(Icons.directions_car, AppStrings.cars.tr, AppStrings.mainServicesCarDesc.tr, gold),
            _buildServiceItem(Icons.checkroom, AppStrings.dresses.tr, AppStrings.mainServicesDressDesc.tr, gold),
            _buildServiceItem(Icons.home_work, AppStrings.halls.tr, AppStrings.mainServicesHallsDesc.tr, gold),

            const SizedBox(height: 25),

            _buildSectionTitle(AppStrings.whoBenefits.tr, maroon),
            _buildTargetCard(AppStrings.serviceProvidersBenefit.tr, AppStrings.serviceProvidersBenefitDesc.tr, Icons.storefront, maroon),
            _buildTargetCard(AppStrings.serviceSeekersBenefit.tr, AppStrings.serviceSeekersBenefitDesc.tr, Icons.person_search, maroon),

            const SizedBox(height: 30),

            Center(
              child: Text(
                AppStrings.mabroukJoyOnUs.tr,
                style: const TextStyle(color: maroon, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color maroon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: maroon),
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildServiceItem(IconData icon, String title, String desc, Color gold) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: gold),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildTargetCard(String title, String desc, IconData icon, Color maroon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: maroon.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: maroon)),
                Text(desc, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Icon(icon, size: 30, color: maroon),
        ],
      ),
    );
  }
}
