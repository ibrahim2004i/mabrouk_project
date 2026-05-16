import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/network/api_upload_service.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/data/reference_repository.dart';
import 'package:mabrouk_app/features/services/data/service_repository.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';
import 'package:mabrouk_app/shared/widgets/app_drawer.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final ServiceBase? existingService;
  const AddServiceScreen({super.key, this.existingService});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedType;
  late String _offeringType;
  late String _priceUnit;
  late int _selectedCityId;

  bool _isLoading = false;
  double _uploadProgress = 0;
  List<File> _selectedImages = [];

  static const Color maroon = Color(0xFF600000);
  static const Color beige = AppTheme.luxuryBeige;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _stockController = TextEditingController(text: '1');

  final _capacityController = TextEditingController();

  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();

  final _modelController = TextEditingController();
  final _brandController = TextEditingController();
  final _yearController = TextEditingController();

  final List<({TextEditingController label, TextEditingController value})>
      _specControllers = [];
      bool _canPurchase(String type) {
  return type == 'dress' || type == 'suit' || type == 'cake';
}

bool _canBook(String type) {
  return type != 'cake';
}

void _fixOfferingTypeForSelectedService() {
  if (!_canBook(_selectedType)) {
    _offeringType = 'purchase';
  } else if (!_canPurchase(_selectedType)) {
    _offeringType = 'booking';
  }
}

  @override
  void initState() {
    super.initState();
    final s = widget.existingService;

    _selectedType = s?.type ?? 'hall';
    _offeringType = s != null
        ? (s.offeringType == OfferingType.purchase ? 'purchase' : 'booking')
        : 'booking';
    _priceUnit = s != null
        ? (s.priceUnit == PriceUnit.hour
            ? 'hour'
            : (s.priceUnit == PriceUnit.day ? 'day' : 'event'))
        : 'event';
    _selectedCityId = s?.cityId ?? 1;
    _fixOfferingTypeForSelectedService();

    if (s != null) {
      _titleController.text = s.title;
      _priceController.text = s.price.toString();
      _descriptionController.text = s.description ?? '';
      _locationController.text = s.locationAddress ?? '';
      _phoneController.text = s.phoneNumber ?? '';
      _whatsappController.text = s.whatsappNumber ?? '';
      _stockController.text = s.stockCount.toString();

      if (s is WeddingHall) {
        _capacityController.text = s.maxCapacity.toString();
      } else if (s is Chalet) {
        _capacityController.text = s.roomsCount.toString();
      } else if (s is Dress) {
        _sizeController.text = s.sizes;
      } else if (s is Suit) {
        _sizeController.text = s.sizes ?? '';
      } else if (s is Car) {
        _brandController.text = s.brand;
        _modelController.text = s.model;
        _yearController.text = s.year?.toString() ?? '';
      } else if (s is Photographer) {
        _descriptionController.text = s.packageDetails;
      } else if (s is OtherService) {
        _modelController.text = s.typeName;
      }

      for (final spec in s.specifications) {
        _specControllers.add((
          label: TextEditingController(text: spec.label),
          value: TextEditingController(text: spec.value),
        ));
      }
    }
  }

  void _addSpecification() {
    setState(() {
      _specControllers.add((
        label: TextEditingController(),
        value: TextEditingController(),
      ));
    });
  }

  void _removeSpecification(int index) {
    setState(() {
      _specControllers[index].label.dispose();
      _specControllers[index].value.dispose();
      _specControllers.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showReelsComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_text('إضافة فيديوهات الريلز قريبًا', 'Reels videos coming soon')),
        backgroundColor: maroon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _text(String ar, String en) {
    return Get.locale?.languageCode == 'ar' ? ar : en;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _stockController.dispose();
    _capacityController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _modelController.dispose();
    _brandController.dispose();
    _yearController.dispose();

    for (final ctrl in _specControllers) {
      ctrl.label.dispose();
      ctrl.value.dispose();
    }

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      final Map<String, dynamic> data = {
        'offering_type': _offeringType,
        'price_unit': _priceUnit,
        'city_id': _selectedCityId,
        'location_address': _locationController.text,
        'office_phone': _phoneController.text,
        'whatsapp_number': _whatsappController.text,
        'stock_count': _offeringType == 'purchase'
            ? (int.tryParse(_stockController.text) ?? 1)
            : 1,
        'specifications': _specControllers
            .where((c) => c.label.text.isNotEmpty)
            .map((c) => {
                  'label': c.label.text,
                  'value': c.value.text,
                })
            .toList(),
      };

      if (_selectedType == 'hall') {
        data['name'] = _titleController.text;
        data['base_price'] = double.parse(_priceController.text);
        data['max_capacity'] = int.parse(_capacityController.text);
        data['description'] = _descriptionController.text;
      } else if (_selectedType == 'chalet') {
        data['name'] = _titleController.text;
        data['price_per_night'] = double.parse(_priceController.text);
        data['rooms_count'] = int.tryParse(_capacityController.text) ?? 1;
        data['description'] = _descriptionController.text;
      } else if (_selectedType == 'dress' || _selectedType == 'suit') {
        data['title'] = _titleController.text;
        data['price'] = double.parse(_priceController.text);
        data['sizes_available'] = _sizeController.text;
        data['description'] = _descriptionController.text;
      } else if (_selectedType == 'car') {
        data['name'] = _titleController.text;
        data['brand'] = _brandController.text;
        data['model'] = _modelController.text;
        data['year'] = int.tryParse(_yearController.text);
        data['price_per_day'] = double.parse(_priceController.text);
        data['description'] = _descriptionController.text;
      } else if (_selectedType == 'cake') {
        data['name'] = _titleController.text;
        data['base_price'] = double.parse(_priceController.text);
        data['description'] = _descriptionController.text;
      } else if (_selectedType == 'photographer') {
        data['package_name'] = _titleController.text;
        data['base_price'] = double.parse(_priceController.text);
        data['package_details'] = _descriptionController.text;
      } else if (_selectedType == 'others') {
        data['type_name'] = _modelController.text;
        data['title'] = _titleController.text;
        data['base_price'] = double.parse(_priceController.text);
        data['description'] = _descriptionController.text;
      }

      if (widget.existingService != null) {
        await ref.read(serviceRepoProvider).updateService(
              _selectedType,
              widget.existingService!.id,
              data,
            );
      } else {
        final newServiceId =
            await ref.read(serviceRepoProvider).createService(_selectedType, data);

        if (_selectedImages.isNotEmpty) {
          await ref.read(apiUploadServiceProvider).uploadServiceMedia(
                newServiceId,
                _selectedType,
                _selectedImages,
                onProgress: (p) => setState(() => _uploadProgress = p),
              );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingService != null
                  ? AppStrings.serviceUpdatedPendingApproval.tr
                  : AppStrings.serviceAddedPendingReview.tr,
            ),
            backgroundColor: maroon,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error.tr}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final isEdit = widget.existingService != null;

    return Scaffold(
      backgroundColor: beige,
      drawer: isEdit ? null : const AppDrawer(),
      appBar: AppBar(
        backgroundColor: maroon,
        foregroundColor: beige,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEdit ? AppStrings.editServiceData.tr : AppStrings.addService.tr,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: beige,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  title: AppStrings.mainServiceType.tr,
                  icon: Icons.category_rounded,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: _inputDecoration(AppStrings.mainServiceType.tr),
                      dropdownColor: beige,
                      items: [
                        DropdownMenuItem(value: 'hall', child: Text(AppStrings.weddingHall.tr)),
                        DropdownMenuItem(value: 'chalet', child: Text(AppStrings.chalet.tr)),
                        DropdownMenuItem(value: 'dress', child: Text(AppStrings.weddingDress.tr)),
                        DropdownMenuItem(value: 'suit', child: Text(AppStrings.mensSuit.tr)),
                        DropdownMenuItem(value: 'car', child: Text(AppStrings.carZaffa.tr)),
                        DropdownMenuItem(value: 'cake', child: Text(AppStrings.cake.tr)),
                        DropdownMenuItem(value: 'photographer', child: Text(AppStrings.photographer.tr)),
                      ],
                      onChanged: (val) {
                        setState(() {
                           _selectedType = val!;
                           _fixOfferingTypeForSelectedService();
                           });
                          },
                        ),
                    const SizedBox(height: 14),
                    citiesAsync.when(
                      data: (cities) => DropdownButtonFormField<int>(
                        value: _selectedCityId,
                        decoration: _inputDecoration(AppStrings.cityGovernorate.tr),
                        dropdownColor: beige,
                        items: cities
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  Get.locale?.languageCode == 'en'
                                      ? (c.nameEn ?? c.nameAr)
                                      : c.nameAr,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCityId = val!),
                      ),
                      loading: () => LinearProgressIndicator(color: maroon),
                      error: (_, __) => Text(AppStrings.loadCitiesFailedMsg.tr),
                    ),
                  ],
                ),

                _sectionCard(
                  title: AppStrings.serviceDeliveryMethod.tr,
                  icon: Icons.swap_horizontal_circle_rounded,
                  children: [
                    Row(
  children: [
    if (_canBook(_selectedType))
      Expanded(
        child: _choiceTile(
          title: AppStrings.booking.tr,
          icon: Icons.calendar_month_rounded,
          selected: _offeringType == 'booking',
          onTap: () => setState(() => _offeringType = 'booking'),
        ),
      ),

    if (_canBook(_selectedType) && _canPurchase(_selectedType))
      const SizedBox(width: 10),

    if (_canPurchase(_selectedType))
      Expanded(
        child: _choiceTile(
          title: AppStrings.purchase.tr,
          icon: Icons.shopping_bag_rounded,
          selected: _offeringType == 'purchase',
          onTap: () => setState(() => _offeringType = 'purchase'),
        ),
      ),
  ],
),
                    if (_offeringType == 'booking') ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _priceUnit,
                        decoration: _inputDecoration(AppStrings.pricingUnitBooking.tr),
                        dropdownColor: beige,
                        items: [
                          DropdownMenuItem(value: 'hour', child: Text(AppStrings.perHour.tr)),
                          DropdownMenuItem(value: 'day', child: Text(AppStrings.perDay.tr)),
                          DropdownMenuItem(value: 'event', child: Text(AppStrings.perEvent.tr)),
                        ],
                        onChanged: (val) => setState(() => _priceUnit = val!),
                      ),
                    ],
                    if (_offeringType == 'purchase') ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          AppStrings.availableQuantity.tr,
                          icon: Icons.inventory_2_outlined,
                          hint: '1',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty || int.tryParse(v) == null)
                                ? AppStrings.fieldRequired.tr
                                : null,
                      ),
                    ],
                  ],
                ),

                _sectionCard(
                  title: AppStrings.serviceInfo.tr,
                  icon: Icons.info_rounded,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration(
                        AppStrings.serviceTitleLabel.tr,
                        icon: Icons.drive_file_rename_outline_rounded,
                      ),
                      validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        _offeringType == 'purchase'
                            ? AppStrings.pricePerPieceLabel.tr
                            : (_priceUnit == 'hour'
                                ? AppStrings.pricePerHourLabel.tr
                                : (_priceUnit == 'day'
                                    ? AppStrings.pricePerDayLabel.tr
                                    : AppStrings.pricePerEventLabel.tr)),
                        icon: Icons.payments_rounded,
                      ),
                      validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        AppStrings.detailedDescriptionLabel.tr,
                        icon: Icons.notes_rounded,
                      ),
                      validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                    ),
                  ],
                ),

                _sectionCard(
                  title: AppStrings.locationContact.tr,
                  icon: Icons.phone_in_talk_rounded,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        AppStrings.contactPhoneCallsLabel.tr,
                        icon: Icons.phone_rounded,
                      ),
                     validator: (v) {
  if (v == null || v.isEmpty)
    return AppStrings.fieldRequired.tr;

  if (v.length < 10)
    return AppStrings.invalidPhoneNumber.tr;

  return null;
},
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        AppStrings.whatsappNumberLabel.tr,
                        icon: Icons.chat_bubble_outline_rounded,
                        hint: AppStrings.phoneHint07.tr,
                      ),
                      validator: (v) {
  if (v == null || v.isEmpty) {
    return AppStrings.fieldRequired.tr;
  }

  if (v.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
    return AppStrings.invalidPhoneNumber.tr;
  }

  return null;
},
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration(
                        AppStrings.detailedLocationLabel.tr,
                        icon: Icons.location_on_rounded,
                      ),
                      validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                    ),
                  ],
                ),

                if (_selectedType == 'hall' || _selectedType == 'chalet')
                  _sectionCard(
                    title: AppStrings.serviceSpecifications.tr,
                    icon: Icons.tune_rounded,
                    children: [
                      TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          _selectedType == 'hall'
                              ? AppStrings.maxCapacityPeopleLabel.tr
                              : AppStrings.roomsCountLabel.tr,
                          icon: _selectedType == 'hall'
                              ? Icons.people_alt_rounded
                              : Icons.door_front_door_rounded,
                        ),
                        validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                      ),
                    ],
                  ),

                if (_selectedType == 'dress' || _selectedType == 'suit')
                  _sectionCard(
                    title: AppStrings.serviceSpecifications.tr,
                    icon: Icons.straighten_rounded,
                    children: [
                      TextFormField(
                        controller: _sizeController,
                        decoration: _inputDecoration(
                          AppStrings.availableSizesLabel.tr,
                          icon: Icons.straighten_rounded,
                        ),
                        validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _colorController,
                        decoration: _inputDecoration(
                          AppStrings.colorLabel.tr,
                          icon: Icons.color_lens_rounded,
                        ),
                        validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                      ),
                    ],
                  ),

                if (_selectedType == 'car')
                  _sectionCard(
                    title: AppStrings.serviceSpecifications.tr,
                    icon: Icons.directions_car_rounded,
                    children: [
                      TextFormField(
                        controller: _brandController,
                        decoration: _inputDecoration(
                          AppStrings.carBrandLabel.tr,
                          icon: Icons.stars_rounded,
                        ),
                        validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _modelController,
                        decoration: _inputDecoration(
                          AppStrings.carTypeModelLabel.tr,
                          icon: Icons.minor_crash_rounded,
                        ),
                        validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          AppStrings.productionYearLabel.tr,
                          icon: Icons.calendar_month_rounded,
                        ),
                        validator: (v) => v!.isEmpty ? AppStrings.fieldRequired.tr : null,
                      ),
                    ],
                  ),

                _sectionCard(
                  title: AppStrings.customAdditionalSpecs.tr,
                  icon: Icons.add_circle_outline_rounded,
                  trailing: IconButton.filled(
                    onPressed: _addSpecification,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: beige,
                    ),
                  ),
                  children: [
                    Text(
                      AppStrings.customSpecsHint.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: maroon.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_specControllers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            AppStrings.noCustomSpecsAdded.tr,
                            style: TextStyle(
                              color: maroon.withOpacity(0.45),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ..._specControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ctrl = entry.value;

                      return Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: beige.withOpacity(0.55),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: maroon.withOpacity(0.10),
    ),
  ),
  child: Column(
    children: [

      TextFormField(
        controller: ctrl.label,
        decoration: _inputDecoration(
          AppStrings.titleExampleEngine.tr,
          hint: AppStrings.titleHint.tr,
          icon: Icons.title_rounded,
        ),
      ),

      const SizedBox(height: 12),

      TextFormField(
        controller: ctrl.value,
        maxLines: 2,
        decoration: _inputDecoration(
          AppStrings.valueExample25l.tr,
          hint: AppStrings.valueHint.tr,
          icon: Icons.notes_rounded,
        ),
      ),

      const SizedBox(height: 8),

      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => _removeSpecification(index),
          icon: const Icon(
            Icons.remove_circle_rounded,
            color: maroon,
          ),
        ),
      ),
    ],
  ),
);
                    }),
                  ],
                ),

                _sectionCard(
                  title: _text('صور الخدمة', 'Service Images'),
                  icon: Icons.image_rounded,
                  trailing: IconButton.filled(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: beige,
                    ),
                  ),
                  children: [
                    if (_selectedImages.isEmpty)
                      _emptyMediaBox(
                        icon: Icons.image_outlined,
                        text: _text('لم يتم اختيار صور بعد', 'No images selected'),
                      )
                    else
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10, top: 10),
                                  width: 105,
                                  height: 105,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: maroon.withOpacity(0.12),
                                    ),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: maroon,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: beige,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),

                _sectionCard(
                  title: _text('فيديوهات الريلز', 'Reels Videos'),
                  icon: Icons.video_collection_rounded,
                  trailing: IconButton.filled(
                    onPressed: _showReelsComingSoon,
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: beige,
                    ),
                  ),
                  children: [
                    GestureDetector(
                      onTap: _showReelsComingSoon,
                      child: Container(
                        height: 112,
                        decoration: BoxDecoration(
                          color: maroon.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: maroon.withOpacity(0.14),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill_rounded,
                              color: maroon.withOpacity(0.75),
                              size: 42,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _text(
                                'إضافة فيديو للريلز قريبًا',
                                'Add reel video soon',
                              ),
                              style: TextStyle(
                                color: maroon.withOpacity(0.75),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      disabledBackgroundColor: maroon.withOpacity(0.45),
                      foregroundColor: beige,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: beige,
                                  strokeWidth: 2,
                                ),
                              ),
                              if (_uploadProgress > 0) ...[
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                  color: beige,
                                  backgroundColor: Colors.white24,
                                ),
                              ],
                            ],
                          )
                        : Text(
                            isEdit
                                ? AppStrings.updateDataNow.tr
                                : AppStrings.addServiceNow.tr,
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
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: maroon.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: maroon, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: maroon,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    String? hint,
    bool dense = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: dense,
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: maroon.withOpacity(0.75),
              size: 21,
            ),
      labelStyle: TextStyle(
        color: maroon.withOpacity(0.72),
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(
        color: maroon.withOpacity(0.35),
        fontSize: 13,
      ),
      filled: true,
      fillColor: beige.withOpacity(0.65),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: maroon.withOpacity(0.10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: maroon,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _choiceTile({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? maroon : beige.withOpacity(0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? maroon : maroon.withOpacity(0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? beige : maroon,
              size: 24,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                color: selected ? beige : maroon,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyMediaBox({
    required IconData icon,
    required String text,
  }) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: maroon.withOpacity(0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: maroon.withOpacity(0.55), size: 34),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: maroon.withOpacity(0.55),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}