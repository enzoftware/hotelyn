import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/filter/filter.dart';
import 'package:hotelyn/features/home/cubit/nearby_hotels_cubit.dart';
import 'package:hotelyn/features/hotel_detail/hotel_detail.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// Nearby hotels shelf widget displaying hotel items using
/// [CaliforniaProductCard.small] (327×96).
///
/// Complies with Figma node `200:13108` ("Product List 2") and `200:13091`.
/// Supports loading shimmer, loaded list with distance calculation,
/// empty placeholder, error state, and manual location fallback routing
/// if permission is denied.
class NearbyHotelsSection extends StatelessWidget {
  const NearbyHotelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Hotels',
                  style: HotelynTextStyle.h2,
                ),
                TextButton(
                  onPressed: () {
                    final filterCubit = context.read<FilterCubit>();
                    unawaited(
                      HotelFilterBottomSheet.show(
                        context,
                        initialCriteria: filterCubit.state.criteria,
                        onApply: filterCubit.applyCriteria,
                      ),
                    );
                  },
                  child: Text(
                    'Filter',
                    style: HotelynTextStyle.description.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: LocationFallbackBanner(),
          ),
          const SizedBox(height: 8),
          BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              return BlocBuilder<NearbyHotelsCubit, NearbyHotelsState>(
                builder: (context, state) => switch (state) {
                  NearbyHotelsInitial() ||
                  NearbyHotelsLoading() => const _LoadingShimmer(),
                  NearbyHotelsLoaded(:final hotels) => () {
                    final filtered = _applyFilter(hotels, filterState.criteria);
                    if (filtered.isEmpty) {
                      return const _EmptyPlaceholder();
                    }
                    return _NearbyList(hotels: filtered);
                  }(),
                  NearbyHotelsFailure(:final message) => _ErrorCard(
                    message: message,
                  ),
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static List<domain.Hotel> _applyFilter(
    List<domain.Hotel> hotels,
    HotelFilterCriteria criteria,
  ) {
    var result = hotels;

    if (criteria.sortBy == HotelSortOption.nearestDistance) {
      result = List<domain.Hotel>.from(result)
        ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    } else if (criteria.sortBy == HotelSortOption.highestPopularity) {
      result = List<domain.Hotel>.from(result)
        ..sort((a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0));
    }

    return result;
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({required this.hotels});

  final List<domain.Hotel> hotels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var i = 0; i < hotels.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _NearbyHotelItem(hotel: hotels[i]),
          ],
        ],
      ),
    );
  }
}

class _NearbyHotelItem extends StatelessWidget {
  const _NearbyHotelItem({required this.hotel});

  final domain.Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final distanceText = hotel.distanceKm != null
        ? '${hotel.distanceKm!.toStringAsFixed(1)} km · '
        : '';
    final locationText = '$distanceText${hotel.city}, ${hotel.country}';

    return CaliforniaProductCard.small(
      image: const AssetImage('assets/images/hotelyn/hotelyn.png'),
      title: hotel.name,
      location: locationText,
      pricePerNight: r'$84',
      pricePeriodLabel: ' / Night',
      rating: 4.8,
      reviewCount: 84,
      reviewCountLabel: (count) => ' ($count Reviews)',
      onTap: () {
        unawaited(context.push(HotelDetailPage.route, extra: hotel));
      },
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 36,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'No nearby hotels found in this area.',
              style: HotelynTextStyle.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                final locationState = context.read<LocationCubit>().state;
                unawaited(
                  ManualLocationSheet.show(
                    context,
                    initialLocation: locationState.userLocation,
                    onLocationSelected: context
                        .read<LocationCubit>()
                        .setManualLocation,
                  ),
                );
              },
              child: const Text('Change Location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 32),
              const SizedBox(height: 8),
              Text(
                'Could not load nearby hotels',
                style: HotelynTextStyle.description.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: HotelynTextStyle.description.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      final loc = context
                          .read<LocationCubit>()
                          .state
                          .userLocation;
                      unawaited(
                        context.read<NearbyHotelsCubit>().loadNearbyHotels(
                          latitude: loc.latitude,
                          longitude: loc.longitude,
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final locationState = context.read<LocationCubit>().state;
                      unawaited(
                        ManualLocationSheet.show(
                          context,
                          initialLocation: locationState.userLocation,
                          onLocationSelected: context
                              .read<LocationCubit>()
                              .setManualLocation,
                        ),
                      );
                    },
                    child: const Text('Choose Location'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
