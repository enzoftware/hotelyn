import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';
import 'package:hotelyn/core/domain/models/hotel.dart';

class FeaturedHotelCard extends StatelessWidget {
  const FeaturedHotelCard({
    required this.hotel,
    required this.onBookNow,
    super.key,
  });

  final Hotel hotel;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: LightGreyColors.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HotelImage(),
            const SizedBox(height: 12),
            _HotelInfo(hotel: hotel),
            const SizedBox(height: 8),
            _PerksList(perks: hotel.perks),
            const SizedBox(height: 12),
            _BookNowButton(onPressed: onBookNow),
          ],
        ),
      ),
    );
  }
}

class _HotelImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: PrimaryColors.blue3,
      ),
      child: const Center(
        child: Icon(
          Icons.hotel,
          size: 48,
          color: PrimaryColors.white,
        ),
      ),
    );
  }
}

class _HotelInfo extends StatelessWidget {
  const _HotelInfo({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hotel.name, style: HotelynTextStyle.h3),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.place,
                    size: 14,
                    color: GreyColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      hotel.location,
                      style: HotelynTextStyle.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              r'$' '${hotel.price}',
              style: HotelynTextStyle.h3.copyWith(
                color: PrimaryColors.blue,
              ),
            ),
            const Text(
              'per night',
              style: HotelynTextStyle.description,
            ),
          ],
        ),
      ],
    );
  }
}

class _PerksList extends StatelessWidget {
  const _PerksList({required this.perks});

  final List<Perk> perks;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: perks.map((perk) {
        return Chip(
          label: Text(
            perk.name,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: PrimaryColors.white,
          side: const BorderSide(color: GreyColors.grey3),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

class _BookNowButton extends StatelessWidget {
  const _BookNowButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: PrimaryColors.blue,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Book Now'),
      ),
    );
  }
}
