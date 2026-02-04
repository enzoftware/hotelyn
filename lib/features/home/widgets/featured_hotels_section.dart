import 'dart:async';

import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/core/data/mocks/hotels.dart';
import 'package:hotelyn/features/home/widgets/featured_hotel_card.dart';

class FeaturedHotelsSection extends StatelessWidget {
  const FeaturedHotelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList.list(
        children: [
          const SizedBox(height: 24),
          const Text('Featured Hotels', style: HotelynTextStyle.h2),
          const SizedBox(height: 16),
          ...mockHotels.map(
            (hotel) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FeaturedHotelCard(
                hotel: hotel,
                onBookNow: () {
                  Clarity.setCustomTag('checkout_initiated', hotel.name);
                  unawaited(context.push<void>('/payment'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
