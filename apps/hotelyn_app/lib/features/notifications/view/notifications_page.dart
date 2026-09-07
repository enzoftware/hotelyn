import 'package:flutter/material.dart';
import 'package:hotelyn/components/app_bar.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const route = '/notifications';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HotelynHomeAppBar(
        title: 'Notifications',
        iconData: Icons.notifications_none,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: GreyColors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Notifications',
              style: HotelynTextStyle.h2,
            ),
            SizedBox(height: 8),
            Text(
              'You have no unread notifications at the moment.',
              style: HotelynTextStyle.description,
            ),
          ],
        ),
      ),
    );
  }
}
