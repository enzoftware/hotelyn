import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// Map/location preview card matching Figma node `287:32826`.
class HotelDetailLocationCard extends StatelessWidget {
  const HotelDetailLocationCard({
    required this.hotel,
    this.onViewDetails,
    super.key,
  });

  final domain.Hotel hotel;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final fullLocation = hotel.address ?? '${hotel.city}, ${hotel.country}';

    return Container(
      decoration: BoxDecoration(
        color: CaliforniaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CaliforniaColors.borderDefault),
      ),
      padding: const EdgeInsets.all(CaliforniaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Location',
                style: CaliforniaTypography.h4,
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: Text(
                  'View Details',
                  style: CaliforniaTypography.p14Medium.copyWith(
                    color: CaliforniaColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CaliforniaSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              width: double.infinity,
              color: CaliforniaColors.surfaceMuted,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/hotelyn/hotelyn.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 120,
                    errorBuilder: (_, _, _) => const SizedBox.expand(),
                  ),
                  Container(
                    color: const Color(0x33151B33),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CaliforniaColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 16,
                          color: CaliforniaColors.brandPrimary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            hotel.name,
                            style: CaliforniaTypography.p12Medium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CaliforniaSpacing.md),
          Row(
            children: [
              const Icon(
                CupertinoIcons.placemark,
                size: 18,
                color: CaliforniaColors.textSecondary,
              ),
              const SizedBox(width: CaliforniaSpacing.xs),
              Expanded(
                child: Text(
                  fullLocation,
                  style: CaliforniaTypography.p14Regular.copyWith(
                    color: CaliforniaColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
