import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Reviews section preview matching Figma node `287:32848`.
class HotelDetailReviewsSection extends StatelessWidget {
  const HotelDetailReviewsSection({
    this.onSeeAll,
    super.key,
  });

  final VoidCallback? onSeeAll;

  static const List<({String author, String content, double rating})>
  _sampleReviews = [
    (
      author: 'Kim Borrdy',
      rating: 4.5,
      content:
          'Amazing! The room is good than the picture. '
          'Thanks for amazing experience!',
    ),
    (
      author: 'Mirai Kamazuki',
      rating: 5.0,
      content:
          'The service is on point, and I really like the '
          'facilities. Good job!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: CaliforniaTypography.h4,
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: CaliforniaTypography.p14Medium.copyWith(
                    color: CaliforniaColors.brandPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: CaliforniaSpacing.md),
        for (var i = 0; i < _sampleReviews.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CaliforniaSpacing.md),
              child: Divider(color: CaliforniaColors.divider, height: 1),
            ),
          _ReviewItem(review: _sampleReviews[i]),
        ],
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final ({String author, double rating, String content}) review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: CaliforniaColors.brandSecondary,
              child: Text(
                review.author.isNotEmpty ? review.author[0] : 'U',
                style: CaliforniaTypography.p12Medium.copyWith(
                  color: CaliforniaColors.surfaceElevated,
                ),
              ),
            ),
            const SizedBox(width: CaliforniaSpacing.sm),
            Expanded(
              child: Text(
                review.author,
                style: CaliforniaTypography.p14Medium,
              ),
            ),
            const Icon(
              CupertinoIcons.star_fill,
              size: 14,
              color: CaliforniaColors.warning,
            ),
            const SizedBox(width: 4),
            Text(
              review.rating.toStringAsFixed(1),
              style: CaliforniaTypography.p14Medium.copyWith(
                color: CaliforniaColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: CaliforniaSpacing.xs),
        Text(
          review.content,
          style: CaliforniaTypography.p14Regular.copyWith(
            color: CaliforniaColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
