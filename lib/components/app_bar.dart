import 'package:flutter/widgets.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';

class HotelynHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HotelynHomeAppBar({
    super.key,
    required this.title,
    required this.iconData,
    this.onIconPressed,
  });

  final String title;
  final IconData iconData;
  final VoidCallback? onIconPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: HotelynTextStyle.h1,
          ),
          Icon(iconData, size: 24),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 120);
}
