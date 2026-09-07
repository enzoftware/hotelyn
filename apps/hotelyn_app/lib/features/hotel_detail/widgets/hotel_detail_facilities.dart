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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: CaliforniaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CaliforniaColors.borderDefault),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ],
            ),
          ),
      ],
    );
  }
}
