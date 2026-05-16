import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/admin/data/admin_repository.dart';

class SubmitComplaintDialog extends ConsumerStatefulWidget {
  final int providerId;
  final String providerName;
  final int? bookingId;

  const SubmitComplaintDialog({
    super.key,
    required this.providerId,
    required this.providerName,
    this.bookingId,
  });

  @override
  ConsumerState<SubmitComplaintDialog> createState() =>
      _SubmitComplaintDialogState();
}

class _SubmitComplaintDialogState
    extends ConsumerState<SubmitComplaintDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(adminRepoProvider).submitComplaint(
            providerId: widget.providerId,
            subject: _subjectController.text,
            description: _descriptionController.text,
            bookingId: widget.bookingId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.complaintSentSuccess.tr),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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
    const maroon = Color(0xFF600000);
    const beige = AppTheme.luxuryBeige;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: beige,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: maroon.withOpacity(0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: maroon.withOpacity(0.10),
                    border: Border.all(
                      color: maroon.withOpacity(0.22),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: maroon.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: maroon,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '${AppStrings.submitComplaintAgainst.tr} ${widget.providerName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: maroon,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _subjectController,
                  cursorColor: maroon,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _inputDecoration(
                    label: AppStrings.complaintSubject.tr,
                    hint: AppStrings.complaintSubjectHint.tr,
                    icon: Icons.feedback_outlined,
                  ),
                  validator: (v) =>
                      v!.isEmpty ? AppStrings.subjectRequired.tr : null,
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _descriptionController,
                  cursorColor: maroon,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _inputDecoration(
                    label: AppStrings.complaintDescription.tr,
                    hint: AppStrings.complaintDescriptionHint.tr,
                    icon: Icons.notes_rounded,
                  ),
                  validator: (v) =>
                      v!.isEmpty ? AppStrings.descriptionRequired.tr : null,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: maroon.withOpacity(0.70),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: maroon.withOpacity(0.18),
                            ),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroon,
                          disabledBackgroundColor: maroon.withOpacity(0.45),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: beige,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppStrings.submitComplaint.tr,
                                style: const TextStyle(
                                  color: beige,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    const maroon = Color(0xFF600000);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: maroon.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: maroon,
          size: 20,
        ),
      ),
      labelStyle: TextStyle(
        color: maroon.withOpacity(0.78),
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(
        color: Colors.black.withOpacity(0.35),
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.62),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: maroon.withOpacity(0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: maroon,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),
    );
  }
}