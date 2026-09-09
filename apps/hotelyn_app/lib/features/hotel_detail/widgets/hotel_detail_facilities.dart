import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';

/// Horizontal list of hotel facilities with clean icon tiles matching Figma
/// node `139:3222`.
class HotelDetailFacilities extends StatelessWidget {
  const HotelDetailFacilities({super.key});

  static const List<({IconData icon, String label})> _facilities = [
    (icon: CupertinoIcons.wifi, label: 'Wifi'),
    (icon: CupertinoIcons.drop, label: 'Shower'),
    (icon: CupertinoIcons.sunrise, label: 'Breakfast'),
    (icon: CupertinoIcons.sportscourt, label: 'Gym'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in _facilities)
          Flexible(
            child: Container(
              constraints: const BoxConstraints(minWidth: 64, minHeight: 72),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: CaliforniaSpacing.xs,
                vertical: CaliforniaSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: CaliforniaColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CaliforniaColors.borderDefault),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: CaliforniaColors.brandPrimary,
                  ),
                  const SizedBox(height: CaliforniaSpacing.xs),
                  Text(
                    item.label,
                    style: CaliforniaTypography.p12Medium.copyWith(
                      color: CaliforniaColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
