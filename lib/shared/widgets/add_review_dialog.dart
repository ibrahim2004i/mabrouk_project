import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/data/review_repository.dart';

class AddReviewDialog extends ConsumerStatefulWidget {
  final int? bookingId;
  final int? providerId;
  final String? serviceType;
  final int? serviceId;
  final String serviceName;
  final Function() onReviewAdded;

  const AddReviewDialog({
    super.key,
    this.bookingId,
    this.providerId,
    this.serviceType,
    this.serviceId,
    required this.serviceName,
    required this.onReviewAdded,
  });

  @override
  ConsumerState<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends ConsumerState<AddReviewDialog>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final Color maroon = const Color(0xFF600000);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.primaryMaroon,
      elevation: 10,
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      content: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppTheme.luxuryBeige,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.pleaseSelectRating.tr,
              style: const TextStyle(
                color: AppTheme.luxuryBeige,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  return;
}

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        'rating': _rating,
        'comment': _commentController.text,
      };

      if (widget.bookingId != null) {
        data['booking_id'] = widget.bookingId;
      } else {
        data['provider_id'] = widget.providerId;
        data['service_type'] = widget.serviceType;
        data['service_id'] = widget.serviceId;
      }

      await ref.read(reviewRepoProvider).submitReview(data);

      if (!mounted) return;

      Navigator.pop(context);

      widget.onReviewAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
  behavior: SnackBarBehavior.floating,
  backgroundColor: AppTheme.primaryMaroon,
  elevation: 12,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  margin: const EdgeInsets.all(14),
  content: Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppTheme.luxuryBeige,
          size: 20,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          AppStrings.reviewAddedSuccess.tr,
          style: const TextStyle(
            color: AppTheme.luxuryBeige,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.error.tr}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 52),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                maroon,
                const Color(0xFF7A0A0A),
                AppTheme.luxuryBeige,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: maroon.withOpacity(0.35),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// TOP ICON
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.luxuryBeige,
                            Colors.white,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: maroon,
                        size: 55,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TITLE
                    Text(
                      AppStrings.rateService.tr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// SUBTITLE
                    Text(
                      '${AppStrings.experienceWith.tr} ${widget.serviceName}${isArabic ? '؟' : '?'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// STARS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      
                      children: List.generate(5, (index) {
                        final isSelected = index < _rating;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppTheme.luxuryBeige.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.06),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.luxuryBeige
                                            .withOpacity(0.5),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: AppTheme.luxuryBeige,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    /// COMMENT FIELD
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        textAlign:
                            isArabic ? TextAlign.right : TextAlign.left,
                        decoration: InputDecoration(
                          hintText:
                              AppStrings.writeYourReviewNow.tr,
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.45),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                          prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 70),
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: maroon.withOpacity(0.75),
                                size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BUTTON
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.luxuryBeige,
                                elevation: 12,
                                shadowColor:
                                    AppTheme.luxuryBeige.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: maroon,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppStrings.addYourReview.tr,
                                    style: TextStyle(
                                      color: maroon,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}