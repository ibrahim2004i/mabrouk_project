import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mabrouk_app/core/network/api_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:mabrouk_app/features/auth/data/auth_repository.dart';
import 'package:mabrouk_app/features/auth/domain/auth_models.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });

      final url = await ref.read(apiUploadServiceProvider).uploadProfileImage(
        File(pickedFile.path),
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      setState(() => _isUploading = false);
      
      if (url != null) {
        final authState = ref.read(authStateProvider);
        if (authState is AuthSuccess) {
           final currentUser = authState.user;
           final updatedUserJson = currentUser.toJson();
           if (currentUser.role == 'provider') {
              updatedUserJson['logo_url'] = url;
           } else {
              updatedUserJson['profile_image'] = url;
           }
           ref.read(authStateProvider.notifier).updateUserProfile(AuthUser.fromJson(updatedUserJson));
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.successUpdate.tr)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.error.tr), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _deleteProfileImage(String url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.confirm.tr),
        content: const Text("Are you sure you want to delete your profile image?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.cancel.tr)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(AppStrings.delete.tr, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isUploading = true);
      final success = await ref.read(apiUploadServiceProvider).deleteImage(url);
      setState(() => _isUploading = false);

      if (success) {
        // Update local state to remove image URL
        final authState = ref.read(authStateProvider);
        if (authState is AuthSuccess) {
          final currentUser = authState.user;
          final updatedUserJson = currentUser.toJson();
          if (currentUser.role == 'provider') {
            updatedUserJson['logo_url'] = null;
          } else {
            updatedUserJson['profile_image'] = null;
          }
          ref.read(authStateProvider.notifier).updateUserProfile(AuthUser.fromJson(updatedUserJson));
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image deleted successfully")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.error.tr), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    if (authState is! AuthSuccess) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final user = authState.user;
    const maroon = AppTheme.primaryMaroon;
    const beige = AppTheme.luxuryBeige;

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        title: Text(AppStrings.profileTitle.tr),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Avatar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: maroon,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              padding: const EdgeInsets.only(bottom: 40, top: 10),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentGold, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
                        ),
                        child: ClipOval(
                          child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                            ? Image.network(
                                user.imageUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 120, height: 120, color: Colors.white,
                                  child: const Icon(Icons.person, size: 80, color: maroon),
                                ),
                              )
                            : Container(
                                width: 120, height: 120, color: Colors.white,
                                child: const Icon(Icons.person, size: 80, color: maroon),
                              ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.accentGold,
                        child: _isUploading
                            ? Padding(
                                padding: const EdgeInsets.all(8), 
                                child: CircularProgressIndicator(
                                  value: _uploadProgress > 0 ? _uploadProgress : null,
                                  color: Colors.white, 
                                  strokeWidth: 2
                                )
                              )
                            : IconButton(
                                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                onPressed: _pickAndUploadImage, 
                              ),
                      ),
                      if (!_isUploading && user.imageUrl != null && user.imageUrl!.isNotEmpty)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                              onPressed: () => _deleteProfileImage(user.imageUrl!),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user.name ?? user.brandName ?? AppStrings.defaultUserName.tr,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    user.role == 'provider' ? AppStrings.provider.tr : AppStrings.customer.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle(AppStrings.personalInfo.tr),
                  const SizedBox(height: 15),
                  _buildInfoCard([
                    _buildInfoTile(Icons.person_outline, AppStrings.fullName.tr, user.name ?? user.brandName ?? AppStrings.unnamed.tr),
                    _buildInfoTile(Icons.phone_android_outlined, AppStrings.phoneNumber.tr, user.phoneNumber),
                    if (user.role == 'customer' && user.gender != null)
                      _buildInfoTile(Icons.wc, AppStrings.gender.tr, user.gender == 'male' ? AppStrings.male.tr : AppStrings.female.tr),
                    _buildInfoTile(Icons.location_on_outlined, AppStrings.city.tr, AppStrings.defaultLocation.tr),
                  ]),
                  const SizedBox(height: 30),
                  
                  if (user.role == 'provider') ...[
                    _buildSectionTitle(AppStrings.businessInfo.tr),
                    const SizedBox(height: 15),
                    _buildInfoCard([
                      _buildInfoTile(Icons.storefront_outlined, AppStrings.brandName.tr, user.brandName ?? AppStrings.unnamed.tr),
                      if (user.legalName != null)
                        _buildInfoTile(Icons.assignment_ind_outlined, AppStrings.legalName.tr, user.legalName!),
                      if (user.officePhone != null)
                        _buildInfoTile(Icons.phone_forwarded, AppStrings.officePhone.tr, user.officePhone!),
                      if (user.bioDescription != null)
                         _buildInfoTile(Icons.description_outlined, AppStrings.bioDescription.tr, user.bioDescription!),
                      _buildInfoTile(Icons.verified_user_outlined, AppStrings.accountStatus.tr, AppStrings.verified.tr),
                    ]),
                    const SizedBox(height: 30),
                  ],

                  ElevatedButton(
                    onPressed: () => _showEditDialog(context, ref, user), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(AppStrings.updateData.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, dynamic user) {
    final nameController = TextEditingController(text: user.name ?? user.brandName);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final legalNameController = TextEditingController(text: user.role == 'provider' ? user.legalName : '');
    final officePhoneController = TextEditingController(text: user.role == 'provider' ? user.officePhone : '');
    final addressController = TextEditingController(text: user.role == 'provider' ? user.addressDetails : '');
    final bioController = TextEditingController(text: user.role == 'provider' ? user.bioDescription : '');
    
    String? selectedGender = user.role == 'customer' ? user.gender : null;
    int? selectedCityId = user.role == 'customer' ? user.preferredCityId : user.cityId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppStrings.updateData.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  
                  _buildLabel(AppStrings.phoneNumber.tr),
                  _buildTextField(phoneController, Icons.phone, AppStrings.enterPhone.tr),
                  
                  if (user.role == 'customer') ...[
                    _buildLabel(AppStrings.fullName.tr),
                    _buildTextField(nameController, Icons.person, AppStrings.enterNameHint.tr),
                    _buildLabel(AppStrings.gender.tr),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: _inputDecoration(Icons.wc),
                      items: [
                        DropdownMenuItem(value: 'male', child: Text(AppStrings.male.tr)),
                        DropdownMenuItem(value: 'female', child: Text(AppStrings.female.tr)),
                      ],
                      onChanged: (val) => setModalState(() => selectedGender = val),
                    ),
                  ],
                  
                  if (user.role == 'provider') ...[
                    _buildLabel(AppStrings.brandName.tr),
                    _buildTextField(nameController, Icons.store, AppStrings.enterBrandHint.tr),
                    _buildLabel(AppStrings.legalName.tr),
                    _buildTextField(legalNameController, Icons.assignment_ind, AppStrings.enterLegalNameHint.tr),
                    _buildLabel(AppStrings.officePhone.tr),
                    _buildTextField(officePhoneController, Icons.phone_forwarded, AppStrings.enterOfficePhoneHint.tr),
                    _buildLabel(AppStrings.addressDetails.tr),
                    _buildTextField(addressController, Icons.location_on, AppStrings.enterAddressHint.tr),
                    _buildLabel(AppStrings.bioDescription.tr),
                    _buildTextField(bioController, Icons.description, AppStrings.enterBioHint.tr, maxLines: 3),
                  ],

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      final data = {
                        'phone_number': phoneController.text,
                        'full_name': nameController.text, 
                        'brand_name': nameController.text, 
                        'gender': selectedGender,
                        'city_id': selectedCityId ?? 1,
                        'legal_name': legalNameController.text,
                        'office_phone': officePhoneController.text,
                        'address_details': addressController.text,
                        'bio_description': bioController.text,
                      };
                      
                      try {
                        final newUser = await ref.read(authRepoProvider).updateProfile(data);
                        ref.read(authStateProvider.notifier).updateUserProfile(newUser);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.successUpdate.tr)));
                        }
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.error.tr}: $e'), backgroundColor: Colors.red));
                         }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMaroon,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(AppStrings.saveChanges.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(icon).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppTheme.accentGold, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.get3DShadows(),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentGold),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryMaroon)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
    );
  }
}
