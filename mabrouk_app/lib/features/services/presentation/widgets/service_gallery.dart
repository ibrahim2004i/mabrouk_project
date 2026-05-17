import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';

class ServiceGallery extends StatefulWidget {
  final List<String> images;
  const ServiceGallery({super.key, required this.images});

  @override
  State<ServiceGallery> createState() => _ServiceGalleryState();
}

class _ServiceGalleryState extends State<ServiceGallery> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.images.isEmpty ? [] : widget.images;

    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(34),
        bottomRight: Radius.circular(34),
      ),
      child: Stack(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 450,
              viewportFraction: 1.0,
              autoPlay: images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 850),
              autoPlayCurve: Curves.easeInOut,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: images.map((url) {
              return Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: double.infinity,
                  color: maroon,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: beige.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: beige.withOpacity(0.18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 58,
                            color: beige.withOpacity(0.70),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.attachmentsNotAvailable.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: beige,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      maroon.withOpacity(0.30),
                      Colors.transparent,
                      maroon.withOpacity(0.36),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (images.length > 1)
            Positioned(
              bottom: 22,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  final bool isActive = _currentIndex == entry.key;

                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                      width: isActive ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? beige
                            : beige.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: maroon.withOpacity(0.20),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}