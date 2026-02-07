import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class ProfileOptionsSection extends StatelessWidget {
  const ProfileOptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: HotelynTextStyle.h3,
        ),
        const SizedBox(height: 20),
        OptionItemCard(
          optionItem: OptionItem(
            title: 'Favourites',
            iconData: Icons.favorite_border,
          ),
        ),
        OptionItemCard(
          optionItem: OptionItem(
            title: 'Transactions',
            iconData: Icons.timelapse,
            onTap: () => context.push('/payment'),
          ),
        ),
        OptionItemCard(
          optionItem: OptionItem(
            title: 'Cupons',
            iconData: Icons.discount_outlined,
          ),
        ),
        _LogOutOptionCard(),
      ],
    );
  }
}

class OptionItemCard extends StatelessWidget {
  const OptionItemCard({
    required this.optionItem,
    super.key,
    this.itemColor = Colors.black,
    this.hasTrailing = true,
  });

  factory OptionItemCard.delete({required OptionItem optionItem}) {
    return OptionItemCard(
      optionItem: optionItem,
      itemColor: RedColors.red,
      hasTrailing: false,
    );
  }

  final OptionItem optionItem;
  final Color? itemColor;
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const StadiumBorder(),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 14,
      ),
      titleTextStyle: const TextStyle(fontSize: 14),
      title: Text(optionItem.title),
      leading: Icon(optionItem.iconData, size: 24),
      iconColor: itemColor,
      textColor: itemColor,
      trailing: hasTrailing
          ? const Icon(
              Icons.navigate_next_outlined,
              color: LightGreyColors.lightGrey3,
            )
          : null,
      style: ListTileStyle.drawer,
      onTap: optionItem.onTap,
    );
  }
}

class _LogOutOptionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const StadiumBorder(),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 14,
      ),
      titleTextStyle: const TextStyle(fontSize: 14),
      title: const Text('Log Out'),
      leading: const Icon(Icons.logout_outlined, size: 24),
      iconColor: RedColors.red,
      textColor: RedColors.red,
      style: ListTileStyle.drawer,
      onTap: () {
        Clarity.setCustomTag('logout', 'profile');
        context.go('/login');
      },
    );
  }
}

class OptionItem {
  OptionItem({
    required this.title,
    this.iconData,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;
  final IconData? iconData;
}
