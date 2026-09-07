import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/text_input/hotelyn_search_input.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/features/location/location.dart';

const _cardElevation = 2.0;

class HotelynHeader extends SliverPersistentHeaderDelegate {
  final _maxExtent = 250.0;
  final _minExtent = 240.0;

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
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final cityName = state.userLocation.cityName;

        return GestureDetector(
          onTap: () {
            final cubit = context.read<LocationCubit>();
            if (state.isDenied || state.userLocation.isManualFallback) {
              unawaited(
                ManualLocationSheet.show(
                  context,
                  initialLocation: state.userLocation,
                  onLocationSelected: cubit.setManualLocation,
                ),
              );
            } else {
              unawaited(
                LocationPrimingSheet.show<void>(
                  context,
                  onEnableLocation: cubit.requestPermissionFromPriming,
                  onEnterManually: () {
                    unawaited(
                      ManualLocationSheet.show(
                        context,
                        initialLocation: state.userLocation,
                        onLocationSelected: cubit.setManualLocation,
                      ),
                    );
                  },
                ),
              );
            }
          },
          child: Card(
            color: PrimaryColors.white,
            elevation: _cardElevation,
            shape: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: CaliforniaColors.brandPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cityName,
                    style: CaliforniaTypography.p14Medium.copyWith(
                      color: CaliforniaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: CaliforniaColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
