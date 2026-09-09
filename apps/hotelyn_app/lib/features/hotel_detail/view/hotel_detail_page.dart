import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/filter/filter.dart';
import 'package:hotelyn/features/hotel_detail/cubit/hotel_detail_cubit.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_bottom_bar.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_facilities.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_location_card.dart';
import 'package:hotelyn/features/hotel_detail/widgets/hotel_detail_reviews_section.dart';
import 'package:hotelyn/features/payment/view/payment_page.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

/// Hotel detail screen displaying photos, description, amenities, location,
/// reviews, and live room availability booking bar.
///
/// Complies with Figma frame `59:1882` ("05 - Detail").
class HotelDetailPage extends StatelessWidget {
  const HotelDetailPage({
    required this.hotel,
    this.cubit,
    super.key,
  });

  static const route = '/hotel-detail';

  final domain.Hotel hotel;
  final HotelDetailCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _HotelDetailView(hotel: hotel),
      );
    }

    return BlocProvider(
      create: (context) {
        final apiClient = context.read<HotelynApiClient?>();
        final c = HotelDetailCubit(hotel: hotel, apiClient: apiClient);
        unawaited(c.checkAvailability());
        return c;
      },
      child: _HotelDetailView(hotel: hotel),
    );
  }
}

class _HotelDetailView extends StatefulWidget {
  const _HotelDetailView({required this.hotel});

  final domain.Hotel hotel;

  @override
  State<_HotelDetailView> createState() => _HotelDetailViewState();
}

class _HotelDetailViewState extends State<_HotelDetailView> {
  bool _isDescriptionExpanded = false;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final distanceText = hotel.distanceKm != null
        ? '${hotel.distanceKm!.toStringAsFixed(1)} km · '
        : '';
    final locationText = '$distanceText${hotel.city}, ${hotel.country}';
    final description =
        hotel.description ??
        '${hotel.name} is a high rated hotel in ${hotel.city}, '
            '${hotel.country} with luxury amenities, comfortable rooms, '
            'and exceptional customer service.';

    return Scaffold(
      backgroundColor: CaliforniaColors.surfacePrimary,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroImageHeader(
                  hotel: hotel,
                  isLiked: _isLiked,
                  onLikeToggle: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CaliforniaSpacing.xl,
                    vertical: CaliforniaSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: CaliforniaTypography.h2,
                      ),
                      const SizedBox(height: CaliforniaSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.placemark,
                            size: 16,
                            color: CaliforniaColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationText,
                              style: CaliforniaTypography.p14Regular.copyWith(
                                color: CaliforniaColors.textSecondary,
                              ),
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: CaliforniaColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hotel.rating.toStringAsFixed(1)} '
                            '(${hotel.reviewCount}+ Reviews)',
                            style: CaliforniaTypography.p14Medium.copyWith(
                              color: CaliforniaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: CaliforniaSpacing.lg),
                      Text(
                        description,
                        style: CaliforniaTypography.p14Regular.copyWith(
                          color: CaliforniaColors.textSecondary,
                        ),
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow: _isDescriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Text(
                          _isDescriptionExpanded ? 'Read Less' : 'Read More',
                          style: CaliforniaTypography.p14Medium.copyWith(
                            color: CaliforniaColors.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: CaliforniaSpacing.xxl),
                      const Text(
                        'Facilities',
                        style: CaliforniaTypography.h4,
                      ),
                      const SizedBox(height: CaliforniaSpacing.md),
                      const HotelDetailFacilities(),
                      const SizedBox(height: CaliforniaSpacing.xxl),
                      HotelDetailLocationCard(hotel: hotel),
                      const SizedBox(height: CaliforniaSpacing.xxl),
                      const HotelDetailReviewsSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocBuilder<HotelDetailCubit, HotelDetailState>(
              builder: (context, state) {
                final displayPrice = state.rooms.isNotEmpty
                    ? '\$${state.rooms.first.pricePerNight.toStringAsFixed(0)}'
                    : '\$${hotel.pricePerNight.round()}';
                final isAvailable =
                    state.status != HotelDetailStatus.loading &&
                    state.hasAvailableRoom;
                return HotelDetailBottomBar(
                  price: displayPrice,
                  isAvailable: isAvailable,
                  onBookNow: () {
                    unawaited(context.push(PaymentPage.route));
                  },
                  onMessageTap: () {
                    // Quick route to messages or support
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageHeader extends StatelessWidget {
  const _HeroImageHeader({
    required this.hotel,
    required this.isLiked,
    required this.onLikeToggle,
  });

  final domain.Hotel hotel;
  final bool isLiked;
  final VoidCallback onLikeToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: Image.asset(
            'assets/images/hotelyn/hotelyn.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: CaliforniaColors.surfaceMuted,
              child: Icon(Icons.hotel, size: 64),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CaliforniaSpacing.md,
              vertical: CaliforniaSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CaliforniaTopBarCircleButton(
                  icon: CupertinoIcons.back,
                  scrim: true,
                  onTap: () => Navigator.of(context).pop(),
                  semanticLabel: 'Back',
                ),
                Row(
                  children: [
                    CaliforniaTopBarCircleButton(
                      icon: CupertinoIcons.share,
                      scrim: true,
                      onTap: () {
                        // Share intent
                      },
                      semanticLabel: 'Share',
                    ),
                    const SizedBox(width: CaliforniaSpacing.sm),
                    CaliforniaTopBarCircleButton(
                      icon: isLiked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      scrim: true,
                      onTap: onLikeToggle,
                      semanticLabel: 'Favorite',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
