import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _placeholderImageUrl =
    'https://images.unsplash.com/photo-1566073771259-6a8506099945'
    '?w=640&q=80';

const _facilities = [
  CaliforniaProductFacility(icon: CupertinoIcons.bed_double, label: '2 Beds'),
  CaliforniaProductFacility(icon: CupertinoIcons.wifi, label: 'Wifi'),
  CaliforniaProductFacility(
    icon: CupertinoIcons.sportscourt,
    label: 'Gym',
  ),
];

@widgetbook.UseCase(name: 'Large', type: CaliforniaProductCard)
Widget buildCaliforniaProductCardLargeUseCase(BuildContext context) {
  return CaliforniaProductCard.large(
    image: const NetworkImage(_placeholderImageUrl),
    title: context.knobs.string(
      label: 'title',
      initialValue: 'Diamond Heart Hotel',
    ),
    location: context.knobs.string(
      label: 'location',
      initialValue: 'Purwokerto, Karang Lewas',
    ),
    pricePerNight: context.knobs.string(
      label: 'pricePerNight',
      initialValue: r'$46',
    ),
    pricePeriodLabel: context.knobs.string(
      label: 'pricePeriodLabel',
      initialValue: 'Per Night',
    ),
    rating: context.knobs.doubleOrNull.slider(
      label: 'rating',
      initialValue: 4.6,
      max: 5,
    ),
    facilities:
        context.knobs.boolean(
          label: 'with facilities',
          initialValue: true,
        )
        ? _facilities
        : const [],
    onTap: () {},
  );
}

@widgetbook.UseCase(name: 'Medium', type: CaliforniaProductCard)
Widget buildCaliforniaProductCardMediumUseCase(BuildContext context) {
  return CaliforniaProductCard.medium(
    image: const NetworkImage(_placeholderImageUrl),
    title: context.knobs.string(
      label: 'title',
      initialValue: 'Diamond Heart Hotel',
    ),
    location: context.knobs.string(
      label: 'location',
      initialValue: 'Purwokerto, Street No 31, Central Java',
    ),
    pricePerNight: context.knobs.string(
      label: 'pricePerNight',
      initialValue: r'$46',
    ),
    priceSuffix: context.knobs.stringOrNull(
      label: 'priceSuffix',
      initialValue: '/Night',
    ),
    facilities:
        context.knobs.boolean(
          label: 'with facilities',
          initialValue: true,
        )
        ? _facilities.take(2).toList()
        : const [],
    onTap: () {},
  );
}

@widgetbook.UseCase(name: 'Small', type: CaliforniaProductCard)
Widget buildCaliforniaProductCardSmallUseCase(BuildContext context) {
  return CaliforniaProductCard.small(
    image: const NetworkImage(_placeholderImageUrl),
    title: context.knobs.string(
      label: 'title',
      initialValue: 'Hyatt Washington Hotel',
    ),
    location: context.knobs.string(
      label: 'location',
      initialValue: 'Purwokerto, Glempang',
    ),
    pricePerNight: context.knobs.string(
      label: 'pricePerNight',
      initialValue: r'$38',
    ),
    pricePeriodLabel: context.knobs.string(
      label: 'pricePeriodLabel',
      initialValue: ' / Night',
    ),
    rating: context.knobs.doubleOrNull.slider(
      label: 'rating',
      initialValue: 4.2,
      max: 5,
    ),
    reviewCount: context.knobs.intOrNull.input(
      label: 'reviewCount',
      initialValue: 84,
    ),
    reviewCountLabel: (count) =>
        '($count ${count == 1 ? 'Review' : 'Reviews'})',
    onTap: () {},
  );
}

@widgetbook.UseCase(name: 'All sizes', type: CaliforniaProductCard)
Widget buildCaliforniaProductCardAllSizesUseCase(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        const CaliforniaProductCard.large(
          image: NetworkImage(_placeholderImageUrl),
          title: 'Diamond Heart Hotel',
          location: 'Purwokerto, Karang Lewas',
          pricePerNight: r'$46',
          pricePeriodLabel: 'Per Night',
          rating: 4.6,
          facilities: _facilities,
        ),
        CaliforniaProductCard.medium(
          image: const NetworkImage(_placeholderImageUrl),
          title: 'Diamond Heart Hotel',
          location: 'Purwokerto, Street No 31, Central Java',
          pricePerNight: r'$46',
          priceSuffix: '/Night',
          facilities: _facilities.take(2).toList(),
        ),
        CaliforniaProductCard.small(
          image: const NetworkImage(_placeholderImageUrl),
          title: 'Hyatt Washington Hotel',
          location: 'Purwokerto, Glempang',
          pricePerNight: r'$38',
          pricePeriodLabel: ' / Night',
          rating: 4.2,
          reviewCount: 84,
          reviewCountLabel: (count) =>
              '($count ${count == 1 ? 'Review' : 'Reviews'})',
        ),
      ],
    ),
  );
}
