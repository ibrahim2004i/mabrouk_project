import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/presentation/service_providers.dart';
import 'package:mabrouk_app/features/services/domain/service_filter.dart';
import 'package:mabrouk_app/features/services/data/reference_repository.dart';

import '../../domain/service_models.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final String category;
  const FilterBottomSheet({super.key, required this.category});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ServiceFilter _currentFilter;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  bool get _bookingOnly {
    return ['hall', 'chalet', 'car', 'photographer'].contains(widget.category);
  }

  bool get _bookingAndPurchase {
    return ['dress', 'suit', 'cake'].contains(widget.category);
  }

  @override
  void initState() {
    super.initState();
    _currentFilter = ref.read(serviceFilterProvider);

    if (_bookingOnly) {
      _currentFilter = _currentFilter.copyWith(
        offeringType: OfferingType.booking,
      );
    }

    _minPriceController.text =
        _currentFilter.minPrice?.round().toString() ?? '';
    _maxPriceController.text =
        _currentFilter.maxPrice?.round().toString() ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: maroon.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(servicesProvider.notifier).clearFilters();
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppStrings.reset.tr,
                    style: TextStyle(
                      color: maroon.withOpacity(0.65),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  AppStrings.filterServices.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: maroon,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: maroon),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _sectionCard(
              title: AppStrings.priceRange.tr,
              icon: Icons.payments_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        AppStrings.from.tr,
                        Icons.money_off_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        AppStrings.to.tr,
                        Icons.attach_money_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: AppStrings.cityGovernorate.tr,
              icon: Icons.location_on_rounded,
              child: citiesAsync.when(
                data: (cities) => DropdownButtonFormField<int?>(
                  value: _currentFilter.cityId,
                  dropdownColor: beige,
                  decoration: _inputDecoration(
                    AppStrings.chooseCity.tr,
                    Icons.location_city_rounded,
                  ),
                  hint: Text(AppStrings.chooseCity.tr),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(AppStrings.allCities.tr),
                    ),
                    ...cities.map(
                      (city) => DropdownMenuItem<int?>(
                        value: city.id,
                        child: Text(
                          Get.locale?.languageCode == 'en'
                              ? (city.nameEn ?? city.nameAr)
                              : city.nameAr,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (val == null) {
                        _currentFilter = _currentFilter.copyWith(
                          cityId: null,
                          cityName: null,
                          clearCity: true,
                        );
                      } else {
                        final city = cities.firstWhere((c) => c.id == val);
                        _currentFilter = _currentFilter.copyWith(
                          cityId: city.id,
                          cityName: city.nameAr,
                          clearCity: false,
                        );
                      }
                    });
                  },
                ),
                loading: () => const LinearProgressIndicator(color: maroon),
                error: (_, __) => Text(AppStrings.loadCitiesFailedMsg.tr),
              ),
            ),

            const SizedBox(height: 16),

            if (_bookingAndPurchase)
              _sectionCard(
                title: AppStrings.offeringType.tr,
                icon: Icons.swap_horizontal_circle_rounded,
                child: Row(
                  children: [
                    _buildTypeChip(AppStrings.all.tr, null),
                    const SizedBox(width: 8),
                    _buildTypeChip(AppStrings.booking.tr, OfferingType.booking),
                    const SizedBox(width: 8),
                    _buildTypeChip(AppStrings.purchase.tr, OfferingType.purchase),
                  ],
                ),
              ),

            if (_bookingAndPurchase) const SizedBox(height: 16),

            if (widget.category == 'hall')
              _sectionCard(
                title: AppStrings.minCapacity.tr,
                icon: Icons.groups_rounded,
                child: Slider(
                  value: (_currentFilter.minCapacity ?? 0).toDouble(),
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  activeColor: maroon,
                  inactiveColor: maroon.withOpacity(0.12),
                  label: '${_currentFilter.minCapacity ?? 0}',
                  onChanged: (val) => setState(
                    () => _currentFilter =
                        _currentFilter.copyWith(minCapacity: val.toInt()),
                  ),
                ),
              ),

            if (widget.category == 'chalet')
              _sectionCard(
                title: AppStrings.minRooms.tr,
                icon: Icons.door_front_door_rounded,
                child: Column(
                  children: [
                    Row(
                      children: [1, 2, 3, 4, 5].map((n) {
                        final selected = _currentFilter.minRooms == n;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Center(child: Text('$n')),
                              selected: selected,
                              selectedColor: maroon,
                              backgroundColor: beige.withOpacity(0.75),
                              labelStyle: TextStyle(
                                color: selected ? beige : maroon,
                                fontWeight: FontWeight.w800,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              onSelected: (val) => setState(
                                () => _currentFilter = _currentFilter.copyWith(
                                  minRooms: val ? n : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SwitchListTile(
                      activeColor: maroon,
                      title: Text(
                        AppStrings.hasPool.tr,
                        style: const TextStyle(
                          color: maroon,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      value: _currentFilter.hasPool ?? false,
                      onChanged: (val) => setState(
                        () => _currentFilter =
                            _currentFilter.copyWith(hasPool: val),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final minP = double.tryParse(_minPriceController.text);
                  final maxP = double.tryParse(_maxPriceController.text);

                  var finalFilter = _currentFilter.copyWith(
                    minPrice: minP,
                    maxPrice: maxP,
                  );

                  if (_bookingOnly) {
                    finalFilter = finalFilter.copyWith(
                      offeringType: OfferingType.booking,
                    );
                  }

                  ref.read(servicesProvider.notifier).setFilter(finalFilter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: beige,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  AppStrings.applyFilters.tr,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    const maroon = AppTheme.primaryMaroon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: maroon.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: maroon.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: maroon,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: maroon, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: maroon.withOpacity(0.70), size: 20),
      filled: true,
      fillColor: beige.withOpacity(0.70),
      labelStyle: TextStyle(
        color: maroon.withOpacity(0.60),
        fontWeight: FontWeight.w700,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: maroon.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: maroon, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildTypeChip(String label, OfferingType? type) {
    final isSelected = _currentFilter.offeringType == type;
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(
              offeringType: type,
              clearOffering: type == null,
            );
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? maroon : beige.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? maroon : maroon.withOpacity(0.10),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? beige : maroon,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}