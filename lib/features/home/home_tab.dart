import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_cubit.dart';
import 'package:hotelyn/components/navigation_bar/navigation_bar_state.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/features/messages/messages_tab.dart';
import 'package:hotelyn/features/profile/profile_tab.dart';
import 'package:hotelyn/features/search/search_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBarCubit(),
      child: BlocBuilder<NavigationBarCubit, NavigationBarState>(
        builder: (context, state) {
          final index = state.selectedTabIndex;
          return Scaffold(
            bottomNavigationBar: const HotelynNavigationBar(),
            body: <Widget>[
              const HomeTab(),
              const SearchTab(),
              const MesssagesTab(),
              const ProfileTab()
            ].elementAt(index),
          );
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: HotelynHeader(),
        ),
        const SliverToBoxAdapter(),
      ],
    );
  }
}

const _cardElevation = 2.0;

class HotelynHeader extends SliverPersistentHeaderDelegate {
  final _maxExtent = 350.0;
  final _minExtent = 320.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: const Padding(
        padding: EdgeInsets.only(
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
                LocationCard(),
                NotificationCard(),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Hello, Katherine! 👋',
              style: HotelynTextStyle.description,
            ),
            SizedBox(height: 8),
            Text(
              "Let's find best hotel",
              style: HotelynTextStyle.h1,
            ),
            SizedBox(height: 32),
            // TODO: Split in different widget and pass controller
            TextField(
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

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: HotelynAppColors.white,
      elevation: _cardElevation,
      shape: StadiumBorder(),
      child: Padding(
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
      color: HotelynAppColors.white,
      shape: CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(11.0),
        child: Badge(
          child: Icon(Icons.notifications),
        ),
      ),
    );
  }
}
