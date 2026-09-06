import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/location/cubit/cubit.dart';
import 'package:hotelyn/features/location/models/models.dart';

/// Bottom sheet allowing manual entry or selection of fallback destinations
/// when location permission is denied.
class ManualLocationSheet extends StatefulWidget {
  const ManualLocationSheet({
    super.key,
    this.initialLocation,
    this.onLocationSelected,
  });

  final UserLocation? initialLocation;
  final ValueChanged<UserLocation>? onLocationSelected;

  static Future<UserLocation?> show(
    BuildContext context, {
    UserLocation? initialLocation,
    ValueChanged<UserLocation>? onLocationSelected,
  }) {
    return showModalBottomSheet<UserLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ManualLocationSheet(
            initialLocation: initialLocation,
            onLocationSelected: (location) {
              Navigator.of(sheetContext).pop(location);
              onLocationSelected?.call(location);
            },
          ),
        );
      },
    );
  }

  @override
  State<ManualLocationSheet> createState() => _ManualLocationSheetState();
}

class _ManualLocationSheetState extends State<ManualLocationSheet> {
  late final TextEditingController _cityController;
  late UserLocation _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ?? UserLocation.defaultFallback;
    _cityController = TextEditingController(text: _selectedLocation.cityName);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _confirm() {
    final customName = _cityController.text.trim();
    final finalLocation = customName.isEmpty
        ? _selectedLocation
        : _selectedLocation.cityName == customName
            ? _selectedLocation
            : UserLocation(
                latitude: _selectedLocation.latitude,
                longitude: _selectedLocation.longitude,
                cityName: customName,
                isManualFallback: true,
              );

    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(finalLocation);
    } else {
      unawaited(
        context.read<LocationCubit>().setManualLocation(finalLocation),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CaliforniaColors.surfacePrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: CaliforniaColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Enter Location Manually',
                style: CaliforniaTypography.h2,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a suggested destination or enter your city name '
                'to see hotel recommendations.',
                style: CaliforniaTypography.p14Regular.copyWith(
                  color: CaliforniaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // City text input
              CaliforniaInputField(
                title: 'City or Region',
                placeholder: 'e.g. Purwokerto, IND',
                controller: _cityController,
                leadingIcon: CupertinoIcons.search,
                onChanged: (val) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Suggested Destinations',
                style: CaliforniaTypography.h5,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserLocation.fallbackOptions.map((opt) {
                  final isSelected = _selectedLocation.cityName == opt.cityName;
                  const brandTertiary = CaliforniaColors.brandTertiary;
                  return ChoiceChip(
                    label: Text(opt.cityName),
                    selected: isSelected,
                    selectedColor: brandTertiary.withValues(alpha: 0.3),
                    backgroundColor: CaliforniaColors.surfaceMuted,
                    labelStyle: CaliforniaTypography.p14Medium.copyWith(
                      color: isSelected
                          ? CaliforniaColors.brandPrimary
                          : CaliforniaColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? CaliforniaColors.brandPrimary
                            : CaliforniaColors.borderDefault,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedLocation = opt;
                          _cityController.text = opt.cityName;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              Center(
                child: CaliforniaButton.primary(
                  label: 'Set Location',
                  onPressed: _confirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
