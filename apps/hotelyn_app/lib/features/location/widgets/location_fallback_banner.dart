import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/location/cubit/cubit.dart';
import 'package:hotelyn/features/location/widgets/manual_location_sheet.dart';

/// Informational banner displayed in nearby/recommended hotel sections
/// when location permission is denied, offering manual location entry
/// to avoid empty or broken screens.
class LocationFallbackBanner extends StatelessWidget {
  const LocationFallbackBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (!state.isDenied && !state.userLocation.isManualFallback) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: CaliforniaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CaliforniaColors.borderDefault),
          ),
          child: Row(
            children: [
              Icon(
                state.isDenied
                    ? CupertinoIcons.location_slash
                    : CupertinoIcons.placemark,
                size: 20,
                color: CaliforniaColors.brandPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location: ${state.userLocation.cityName}',
                      style: CaliforniaTypography.p14Medium,
                    ),
                    Text(
                      state.isDenied
                          ? 'Permission denied. '
                                'Select your destination manually.'
                          : 'Manually selected destination.',
                      style: CaliforniaTypography.p12Regular.copyWith(
                        color: CaliforniaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CaliforniaButton.ghost(
                label: 'Change',
                width: 78,
                height: 36,
                onPressed: () {
                  unawaited(
                    ManualLocationSheet.show(
                      context,
                      initialLocation: state.userLocation,
                      onLocationSelected: context
                          .read<LocationCubit>()
                          .setManualLocation,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
