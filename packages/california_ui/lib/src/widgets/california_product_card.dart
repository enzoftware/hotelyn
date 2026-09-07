import 'package:california_ui/src/theme/california_colors.dart';
import 'package:california_ui/src/theme/california_spacing.dart';
import 'package:california_ui/src/theme/california_typography.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

/// A single amenity/facility shown in a [CaliforniaProductCard]'s facility
/// row (e.g. "2 Beds", "Wifi", "Gym").
@immutable
class CaliforniaProductFacility {
  /// Creates a product-card facility entry.
  const CaliforniaProductFacility({required this.icon, required this.label});

  /// Icon representing the facility.
  final IconData icon;

  /// Already-localized facility label (e.g. "2 Beds").
  final String label;
}

/// California UI's product (hotel listing) card, in the three sizes
/// defined by the Figma "Card" component's `Product` variant (node
/// `200:12476`): [CaliforniaProductCard.large], [.medium], and [.small].
///
/// This widget takes plain, typed display values rather than a domain
/// entity — it stays decoupled from `hotelyn_domain` so the same card can
/// be reused for anything shaped like a listing. Map your domain model to
/// these fields at the call site:
///
/// ```dart
/// CaliforniaProductCard.large(
///   image: NetworkImage(hotel.heroImageUrl),
///   title: hotel.name,
///   location: hotel.city,
///   pricePerNight: hotel.formattedPrice,
///   pricePeriodLabel: context.l10n.perNight,
///   rating: hotel.rating,
///   facilities: [
///     CaliforniaProductFacility(
///       icon: CupertinoIcons.bed_double,
///       label: '2 Beds',
///     ),
///     CaliforniaProductFacility(icon: CupertinoIcons.wifi, label: 'Wifi'),
///   ],
///   onTap: () => context.push('/hotels/${hotel.id}'),
/// )
/// ```
class CaliforniaProductCard extends StatelessWidget {
  /// Creates a large product card: full-width hero image with a rating
  /// badge, title/location, right-aligned price, and a facilities row.
  const CaliforniaProductCard.large({
    required this.image,
    required this.title,
    required this.location,
    required this.pricePerNight,
    required this.pricePeriodLabel,
    super.key,
    this.rating,
    this.facilities = const [],
    this.onTap,
  }) : _size = _CaliforniaProductCardSize.large,
       priceSuffix = null,
       reviewCount = null,
       reviewCountLabel = null;

  /// Creates a medium product card: a squarer image with a price badge,
  /// title/location, and a facilities row. Sized for a horizontal list.
  const CaliforniaProductCard.medium({
    required this.image,
    required this.title,
    required this.location,
    required this.pricePerNight,
    super.key,
    this.priceSuffix,
    this.facilities = const [],
    this.onTap,
  }) : _size = _CaliforniaProductCardSize.medium,
       rating = null,
       reviewCount = null,
       reviewCountLabel = null,
       pricePeriodLabel = null;

  /// Creates a small product card: a compact horizontal row with a
  /// thumbnail, title/location, price, and a review count.
  const CaliforniaProductCard.small({
    required this.image,
    required this.title,
    required this.location,
    required this.pricePerNight,
    required this.pricePeriodLabel,
    super.key,
    this.rating,
    this.reviewCount,
    this.reviewCountLabel,
    this.onTap,
  }) : _size = _CaliforniaProductCardSize.small,
       facilities = const [],
       priceSuffix = null,
       assert(
         reviewCount == null || reviewCountLabel != null,
         'reviewCountLabel is required whenever reviewCount is provided.',
       );

  final _CaliforniaProductCardSize _size;

  /// The listing's hero/thumbnail image. Pass `NetworkImage(url)` for a
  /// remote image, or any other [ImageProvider] (`AssetImage`,
  /// `MemoryImage`, a caching provider, etc.).
  final ImageProvider image;

  /// Listing title, e.g. a hotel name.
  final String title;

  /// Listing location/address line.
  final String location;

  /// Already-formatted price string, e.g. `"$46"`.
  final String pricePerNight;

  /// Localized label for the price period, shown after [pricePerNight]
  /// (e.g. `"Per Night"` on [CaliforniaProductCard.large], `" / Night"` on
  /// [CaliforniaProductCard.small]). Supply an already-localized string.
  final String? pricePeriodLabel;

  /// Suffix appended after [pricePerNight] in the medium card's price
  /// badge, e.g. `"/Night"`.
  final String? priceSuffix;

  /// Star rating, shown on [CaliforniaProductCard.large]'s image badge and
  /// [CaliforniaProductCard.small]'s info row when non-null.
  final double? rating;

  /// Review count, shown next to [rating] on
  /// [CaliforniaProductCard.small] when non-null.
  final int? reviewCount;

  /// Builds the localized, pluralized display text for [reviewCount] (e.g.
  /// `(84 Reviews)`). Required on [CaliforniaProductCard.small] whenever
  /// [reviewCount] is non-null; the caller owns pluralization rules.
  final String Function(int count)? reviewCountLabel;

  /// Facility/amenity chips shown on [CaliforniaProductCard.large] and
  /// [CaliforniaProductCard.medium].
  final List<CaliforniaProductFacility> facilities;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = switch (_size) {
      _CaliforniaProductCardSize.large => _CaliforniaLargeProductCard(
        this,
      ),
      _CaliforniaProductCardSize.medium => _CaliforniaMediumProductCard(
        this,
      ),
      _CaliforniaProductCardSize.small => _CaliforniaSmallProductCard(
        this,
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CaliforniaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33A7AEC1),
              blurRadius: 80,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: child,
        ),
      ),
    );
  }
}

enum _CaliforniaProductCardSize { large, medium, small }

class _CaliforniaLargeProductCard extends StatelessWidget {
  const _CaliforniaLargeProductCard(this.card);

  final CaliforniaProductCard card;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CaliforniaProductCardImage(
            image: card.image,
            height: 115,
            badge: card.rating == null
                ? null
                : _CaliforniaRatingBadge(rating: card.rating!),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CaliforniaSpacing.xl,
              CaliforniaSpacing.xxl,
              CaliforniaSpacing.xl,
              CaliforniaSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: CaliforniaTypography.h5,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: CaliforniaSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.location_solid,
                                size: 16,
                                color: CaliforniaColors.textSecondary,
                              ),
                              const SizedBox(width: CaliforniaSpacing.sm),
                              Expanded(
                                child: Text(
                                  card.location,
                                  style: CaliforniaTypography.p12Regular
                                      .copyWith(
                                        color: CaliforniaColors.textSecondary,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: CaliforniaSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          card.pricePerNight,
                          style: CaliforniaTypography.h5.copyWith(
                            color: CaliforniaColors.textBrand,
                          ),
                        ),
                        Text(
                          card.pricePeriodLabel ?? '',
                          style: CaliforniaTypography.p12Regular.copyWith(
                            color: CaliforniaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (card.facilities.isNotEmpty) ...[
                  const SizedBox(height: CaliforniaSpacing.xxxl),
                  const _CaliforniaCardDivider(),
                  const SizedBox(height: CaliforniaSpacing.lg),
                  _CaliforniaFacilitiesRow(facilities: card.facilities),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaliforniaMediumProductCard extends StatelessWidget {
  const _CaliforniaMediumProductCard(this.card);

  final CaliforniaProductCard card;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Padding(
        padding: const EdgeInsets.all(CaliforniaSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CaliforniaProductCardImage(
              image: card.image,
              height: 100,
              borderRadius: 10,
              badge: _CaliforniaPriceBadge(
                price: card.pricePerNight,
                suffix: card.priceSuffix,
              ),
            ),
            const SizedBox(height: CaliforniaSpacing.xxl),
            Text(
              card.title,
              style: CaliforniaTypography.h5,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: CaliforniaSpacing.xs),
            Text(
              card.location,
              style: CaliforniaTypography.p12Regular.copyWith(
                color: CaliforniaColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (card.facilities.isNotEmpty) ...[
              const SizedBox(height: CaliforniaSpacing.xxl),
              const _CaliforniaCardDivider(),
              const SizedBox(height: CaliforniaSpacing.lg),
              _CaliforniaFacilitiesRow(facilities: card.facilities),
            ],
          ],
        ),
      ),
    );
  }
}

class _CaliforniaSmallProductCard extends StatelessWidget {
  const _CaliforniaSmallProductCard(this.card);

  final CaliforniaProductCard card;

  @override
  Widget build(BuildContext context) {
    final reviewCount = card.reviewCount;
    final reviewCountLabel = card.reviewCountLabel;
    final reviewLabel = reviewCount != null && reviewCountLabel != null
        ? ' ${reviewCountLabel(reviewCount)}'
        : null;

    return SizedBox(
      width: 327,
      height: 96,
      child: Padding(
        padding: const EdgeInsets.all(CaliforniaSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CaliforniaProductCardImage(
              image: card.image,
              width: 76,
              height: 76,
              borderRadius: 10,
            ),
            const SizedBox(width: CaliforniaSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: CaliforniaTypography.h5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: CaliforniaSpacing.xs),
                      Text(
                        card.location,
                        style: CaliforniaTypography.p12Regular.copyWith(
                          color: CaliforniaColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            text: card.pricePerNight,
                            style: CaliforniaTypography.h6.copyWith(
                              color: CaliforniaColors.textBrand,
                            ),
                            children: [
                              if (card.pricePeriodLabel != null)
                                TextSpan(
                                  text: card.pricePeriodLabel,
                                  style: CaliforniaTypography.p12Regular
                                      .copyWith(
                                        color: CaliforniaColors.textSecondary,
                                      ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (card.rating != null) ...[
                        const SizedBox(width: CaliforniaSpacing.xl),
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 16,
                          color: CaliforniaColors.warning,
                        ),
                        const SizedBox(width: CaliforniaSpacing.xs),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              text: card.rating!.toStringAsFixed(1),
                              style: CaliforniaTypography.p12Medium.copyWith(
                                color: CaliforniaColors.textPrimary,
                              ),
                              children: [
                                if (reviewLabel != null)
                                  TextSpan(
                                    text: reviewLabel,
                                    style: CaliforniaTypography.p12Regular,
                                  ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaliforniaProductCardImage extends StatelessWidget {
  const _CaliforniaProductCardImage({
    required this.image,
    required this.height,
    this.width,
    this.borderRadius,
    this.badge,
  });

  final ImageProvider image;
  final double height;
  final double? width;
  final double? borderRadius;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(image: image, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33151B33), Color(0x00151B33)],
                ),
              ),
            ),
            if (badge != null)
              Positioned(
                top: CaliforniaSpacing.xl,
                right: CaliforniaSpacing.xl,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CaliforniaRatingBadge extends StatelessWidget {
  const _CaliforniaRatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return _CaliforniaScrimPill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.star_fill,
            size: 16,
            color: CaliforniaColors.warning,
          ),
          const SizedBox(width: CaliforniaSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: CaliforniaTypography.p12Medium.copyWith(
              color: CaliforniaColors.textOnBrand,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaliforniaPriceBadge extends StatelessWidget {
  const _CaliforniaPriceBadge({required this.price, this.suffix});

  final String price;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return _CaliforniaScrimPill(
      child: Text.rich(
        TextSpan(
          text: price,
          style: CaliforniaTypography.p12Medium.copyWith(
            color: CaliforniaColors.textOnBrand,
          ),
          children: [
            if (suffix != null)
              TextSpan(
                text: suffix,
                style: CaliforniaTypography.p12Medium.copyWith(
                  color: CaliforniaColors.divider,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CaliforniaScrimPill extends StatelessWidget {
  const _CaliforniaScrimPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x33151B33),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CaliforniaSpacing.xl,
          vertical: CaliforniaSpacing.sm,
        ),
        child: child,
      ),
    );
  }
}

class _CaliforniaCardDivider extends StatelessWidget {
  const _CaliforniaCardDivider();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: CaliforniaColors.divider),
        ),
      ),
      child: SizedBox(height: 0, width: double.infinity),
    );
  }
}

class _CaliforniaFacilitiesRow extends StatelessWidget {
  const _CaliforniaFacilitiesRow({required this.facilities});

  final List<CaliforniaProductFacility> facilities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < facilities.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CaliforniaSpacing.sm),
              child: _CaliforniaFacilityDot(),
            ),
          _CaliforniaFacilityChip(facility: facilities[i]),
        ],
      ],
    );
  }
}

class _CaliforniaFacilityChip extends StatelessWidget {
  const _CaliforniaFacilityChip({required this.facility});

  final CaliforniaProductFacility facility;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(facility.icon, size: 18, color: CaliforniaColors.textSecondary),
        const SizedBox(width: CaliforniaSpacing.sm),
        Text(
          facility.label,
          style: CaliforniaTypography.p12Regular.copyWith(
            color: CaliforniaColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CaliforniaFacilityDot extends StatelessWidget {
  const _CaliforniaFacilityDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CaliforniaColors.divider,
      ),
    );
  }
}
