import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatsItem(data: StatItemData(title: 'Transactions', value: 26)),
            StatsItem(data: StatItemData(title: 'Review', value: 12)),
            StatsItem(data: StatItemData(title: 'Bookings', value: 4)),
          ],
        ),
      ),
    );
  }
}

class StatsItem extends StatelessWidget {
  const StatsItem({super.key, required this.data});

  final StatItemData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          data.value.toString(),
          style: const TextStyle(
            fontSize: 24,
            color: HotelynAppColors.blue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(data.title, style: HotelynTextStyle.description),
      ],
    );
  }
}

class StatItemData {
  final int value;
  final String title;

  StatItemData({
    required this.value,
    required this.title,
  });
}
