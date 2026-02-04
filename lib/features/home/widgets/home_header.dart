import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

const _cardElevation = 2.0;

class HotelynHeader extends SliverPersistentHeaderDelegate {
  final _maxExtent = 240.0;
  final _minExtent = 190.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LocationCard(),
                NotificationCard(),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Hello, Katherine! 👋',
              style: HotelynTextStyle.description,
            ),
            const SizedBox(height: 8),
            const Text(
              "Let's find best hotel",
              style: HotelynTextStyle.h1,
            ),
            const SizedBox(height: 32),
            // TODO(enzoftware): Split in different widget and pass controller
            if (!overlapsContent)
              const HotelynSearchInput(hintText: 'Search hotel'),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: PrimaryColors.white,
      elevation: _cardElevation,
      shape: StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place),
            SizedBox(width: 8),
            Text('Lima, PE'),
            SizedBox(width: 16),
            Icon(Icons.arrow_circle_down),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: _cardElevation,
      color: PrimaryColors.white,
      shape: CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(11),
        child: Badge(
          child: Icon(Icons.notifications),
        ),
      ),
    );
  }
}
