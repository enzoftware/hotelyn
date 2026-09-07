import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';

/// Bottom booking action bar matching Figma node `287:32849` (Detail Navbar).
class HotelDetailBottomBar extends StatelessWidget {
  const HotelDetailBottomBar({
    required this.price,
    required this.onBookNow,
    this.isAvailable = true,
    this.onMessageTap,
    super.key,
  });

  final String price;
  final VoidCallback? onBookNow;
  final bool isAvailable;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CaliforniaColors.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: Color(0x1FA7AEC1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CaliforniaSpacing.xl,
            vertical: CaliforniaSpacing.md,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onMessageTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CaliforniaColors.borderDefault,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.chat_bubble_2,
                    size: 20,
                    color: CaliforniaColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: CaliforniaSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: CaliforniaTypography.h3.copyWith(
                        color: CaliforniaColors.brandPrimary,
                      ),
                    ),
                    Text(
                      'Per Night',
                      style: CaliforniaTypography.p12Regular.copyWith(
                        color: CaliforniaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CaliforniaButton.primary(
                label: isAvailable ? 'Book Now' : 'Unavailable',
                size: CaliforniaButtonSize.small,
                onPressed: isAvailable ? onBookNow : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
