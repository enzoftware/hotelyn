import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hotelyn/components/lorem_ipsum.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HotelynHeader(),
          ),
          const SliverToBoxAdapter(),
        ],
      ),
      bottomNavigationBar: const HotelynNavigationBar(),
    );
  }
}

class HotelynHeader extends SliverPersistentHeaderDelegate {
  final _maxExtent = 350.0;
  final _minExtent = 320.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final percentage = shrinkOffset / _maxExtent;
    log(percentage.toString());
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 70.0,
          left: 24.0,
          right: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: const ShapeDecoration(
                    shape: StadiumBorder(),
                    color: Colors.red,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place),
                        SizedBox(width: 8),
                        Text('Lima, PE'),
                        SizedBox(width: 16),
                        Icon(Icons.arrow_circle_down)
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.red,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(11.0),
                    child: Badge(
                      child: Icon(Icons.notifications),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Hello, Katherine! 👋',
              style: HotelynTextStyle.description,
            ),
            const SizedBox(height: 8),
            const Text(
              'Let`s find best hotel',
              style: HotelynTextStyle.h1,
            ),
            const SizedBox(height: 32),
            // TODO: Split in different widget and pass controller
            const TextField(
              autofocus: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: HotelynAppColors.lightGrey,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Search hotel',
              ),
            ),
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

class HotelynNavigationBar extends StatelessWidget {
  const HotelynNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        )
      ],
    );
  }
}
