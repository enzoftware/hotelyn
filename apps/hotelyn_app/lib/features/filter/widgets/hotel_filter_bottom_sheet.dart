import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotelyn/components/text_style/hotelyn_text_style.dart';
import 'package:hotelyn/features/filter/models/hotel_filter_criteria.dart';

/// Modal bottom sheet implementing the Figma Filter specification
/// (node `203:5504`).
class HotelFilterBottomSheet extends StatefulWidget {
  const HotelFilterBottomSheet({
    required this.initialCriteria,
    required this.onApply,
    super.key,
  });

  final HotelFilterCriteria initialCriteria;
  final ValueChanged<HotelFilterCriteria> onApply;

  static Future<HotelFilterCriteria?> show(
    BuildContext context, {
    required HotelFilterCriteria initialCriteria,
    ValueChanged<HotelFilterCriteria>? onApply,
  }) {
    return showModalBottomSheet<HotelFilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return HotelFilterBottomSheet(
          initialCriteria: initialCriteria,
          onApply: (criteria) {
            Navigator.of(sheetContext).pop(criteria);
            onApply?.call(criteria);
          },
        );
      },
    );
  }

  @override
  State<HotelFilterBottomSheet> createState() => _HotelFilterBottomSheetState();
}

class _HotelFilterBottomSheetState extends State<HotelFilterBottomSheet> {
  late RangeValues _priceRange;
  late bool _availableNow;
  late double? _selectedRating;
  late Set<HotelAmenity> _selectedAmenities;
  late HotelSortOption _selectedSort;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.initialCriteria.minPrice,
      widget.initialCriteria.maxPrice,
    );
    _availableNow = widget.initialCriteria.availableNow;
    _selectedRating = widget.initialCriteria.minRating;
    _selectedAmenities = Set<HotelAmenity>.from(
      widget.initialCriteria.amenities,
    );
    _selectedSort = widget.initialCriteria.sortBy;
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, 1000);
      _availableNow = false;
      _selectedRating = null;
      _selectedAmenities = <HotelAmenity>{};
      _selectedSort = HotelSortOption.highestPopularity;
    });
  }

  void _apply() {
    final criteria = HotelFilterCriteria(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minRating: _selectedRating,
      availableNow: _availableNow,
      amenities: _selectedAmenities,
      sortBy: _selectedSort,
    );
    widget.onApply(criteria);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter', style: HotelynTextStyle.h2),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset',
                      style: HotelynTextStyle.description.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // First-class "Available Now" toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CaliforniaColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Only show hotels with rooms ready to book',
                            style: HotelynTextStyle.description.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: _availableNow,
                      onChanged: (val) => setState(() => _availableNow = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Price Range Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price Range', style: HotelynTextStyle.h3),
                  Text(
                    '\$${_priceRange.start.round()} - '
                    '\$${_priceRange.end.round()}',
                    style: HotelynTextStyle.description.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                max: 1000,
                divisions: 20,
                labels: RangeLabels(
                  '\$${_priceRange.start.round()}',
                  '\$${_priceRange.end.round()}',
                ),
                onChanged: (values) => setState(() => _priceRange = values),
              ),
              const SizedBox(height: 16),
              // Star Rating Section
              const Text('Rating', style: HotelynTextStyle.h3),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final rating in [5.0, 4.5, 4.0, 3.5, 3.0])
                    ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.star_fill,
                            size: 14,
                            color: CaliforniaColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text('${rating.toStringAsFixed(1)}+'),
                        ],
                      ),
                      selected: _selectedRating == rating,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRating = selected ? rating : null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Sort Option
              const Text('Sort By', style: HotelynTextStyle.h3),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Most Popular'),
                    selected:
                        _selectedSort == HotelSortOption.highestPopularity,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSort = HotelSortOption.highestPopularity;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Lowest Price'),
                    selected: _selectedSort == HotelSortOption.lowestPrice,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSort = HotelSortOption.lowestPrice;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Highest Rating'),
                    selected: _selectedSort == HotelSortOption.highestRating,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSort = HotelSortOption.highestRating;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Nearest First'),
                    selected: _selectedSort == HotelSortOption.nearestDistance,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSort = HotelSortOption.nearestDistance;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Apply Button
              CaliforniaButton.primary(
                label: 'Apply Filter',
                width: double.infinity,
                onPressed: _apply,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
