import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';

class ServiceAttributeGrid extends StatelessWidget {
  final ServiceBase service;
  const ServiceAttributeGrid({super.key, required this.service});

  @override
Widget build(BuildContext context) {
  final List<Map<String, dynamic>> attrs = _getAttributes();
  if (attrs.isEmpty) return const SizedBox.shrink();

  const maroon = AppTheme.primaryMaroon;
  const beige = AppTheme.luxuryBeige;

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: attrs.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.08,
    ),
    itemBuilder: (context, index) {
      final attr = attrs[index];

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              beige.withOpacity(0.92),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: maroon.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: maroon.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: maroon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  (attr['icon'] as IconData?) ?? Icons.info_outline,
                  color: maroon,
                  size: 21,
                ),
              ),
            ),

            const SizedBox(height: 18),
            

            Text(
              (attr['label'] as String?) ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: maroon.withOpacity(0.48),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              (attr['value'] as String?) ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: maroon,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  List<Map<String, dynamic>> _getAttributes() {
    final List<Map<String, dynamic>> attrs = [];
    final service = this.service;

    if (service is WeddingHall) {
      attrs.add({'label': AppStrings.maxCapacity.tr, 'value': '${service.maxCapacity} ${AppStrings.person.tr}', 'icon': Icons.groups_rounded});
      attrs.add({'label': AppStrings.mainServiceType.tr, 'value': service.hallType.tr, 'icon': Icons.business_rounded});
    } else if (service is Chalet) {
      attrs.add({'label': AppStrings.roomsCountLabel.tr, 'value': '${service.roomsCount}', 'icon': Icons.door_front_door_rounded});
      attrs.add({'label': AppStrings.poolStatus.tr, 'value': service.hasPool ? AppStrings.hasPool.tr : AppStrings.noPool.tr, 'icon': Icons.pool_rounded});
    } else if (service is Car) {
      attrs.add({'label': AppStrings.carTypeModelLabel.tr, 'value': service.model, 'icon': Icons.minor_crash_rounded});
      if (service.year != null) {
        attrs.add({'label': AppStrings.productionYearLabel.tr, 'value': service.year.toString(), 'icon': Icons.calendar_month_rounded});
      }
    } else if (service is Dress || service is Suit) {
      final sizes = (service is Dress) ? service.sizes : (service as Suit).sizes;
      if (sizes != null && sizes.isNotEmpty) {
        attrs.add({'label': AppStrings.availableSizesLabel.tr, 'value': sizes, 'icon': Icons.straighten_rounded});
      }
    } else if (service is Cake) {
      attrs.add({'label': AppStrings.preparationDaysCount.tr, 'value': '${service.preparationDays} ${AppStrings.day.tr}', 'icon': Icons.timer_rounded});
    } else if (service is OtherService) {
      attrs.add({'label': AppStrings.category.tr, 'value': service.typeName, 'icon': Icons.label_important_rounded});
    }

    if (service.cityName != null) {
      attrs.add({'label': AppStrings.cityGovernorate.tr, 'value': service.cityName!, 'icon': Icons.location_on_rounded});
    }

    for (final spec in service.specifications) {
      if (spec.label.isNotEmpty && spec.value.isNotEmpty) {
        attrs.add({
          'label': spec.label,
          'value': spec.value,
          'icon': Icons.star_border_rounded,
        });
      }
    }

    return attrs;
  }
}