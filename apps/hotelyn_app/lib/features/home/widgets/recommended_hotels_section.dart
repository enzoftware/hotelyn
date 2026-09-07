import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/home/cubit/recommended_hotels_cubit.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// Horizontal carousel of recommended hotel cards.
///
/// Uses [CaliforniaProductCard.medium] (240 px wide) in a horizontally
/// scrolling list, matching the Figma "Product List 1" component
/// (node `200:13109`).
class RecommendedHotelsSection extends StatelessWidget {
  const RecommendedHotelsSection({super.key});

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
                  'Recommended Hotel',
                  style: HotelynTextStyle.h2,
                ),
                TextButton(
                  onPressed: () {
                    // TODO(FE-1304): Navigate to full recommended list.
                  },
                  child: Text(
                    'See All',
                    style: HotelynTextStyle.description.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<RecommendedHotelsCubit, RecommendedHotelsState>(
            builder: (context, state) => switch (state) {
              RecommendedHotelsInitial() ||
              RecommendedHotelsLoading() => const _LoadingShimmer(),
              RecommendedHotelsLoaded(:final hotels) when hotels.isEmpty =>
                const _EmptyPlaceholder(),
              RecommendedHotelsLoaded(:final hotels) => _HotelCarousel(
                hotels: hotels,
              ),
              RecommendedHotelsFailure(:final message) => _ErrorCard(
                message: message,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _HotelCarousel extends StatelessWidget {
  const _HotelCarousel({required this.hotels});

  final List<domain.Hotel> hotels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: hotels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return SizedBox(
            width: 240,
            child: CaliforniaProductCard.medium(
              image: const AssetImage('assets/images/hotelyn/hotelyn.png'),
              title: hotel.name,
              location: '${hotel.city}, ${hotel.country}',
              pricePerNight: r'$46',
              priceSuffix: '/Night',
              facilities: const [
                CaliforniaProductFacility(
                  icon: CupertinoIcons.bed_double,
                  label: '2 Beds',
                ),
                CaliforniaProductFacility(
                  icon: CupertinoIcons.wifi,
                  label: 'Wifi',
                ),
              ],
              onTap: () {
                // TODO(FE-1305): Navigate to hotel detail.
              },
            ),
          );
        },
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, _) => Container(
          width: 240,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Text(
          'No recommended hotels found nearby.',
          style: HotelynTextStyle.description,
          textAlign: TextAlign.center,
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
                'Could not load recommended hotels',
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
              TextButton(
                onPressed: () {
                  // Retry by re-reading location from cubit.
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
