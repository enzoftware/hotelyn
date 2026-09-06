import 'dart:async';

import 'package:california_ui/california_ui.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotelyn/features/location/cubit/cubit.dart';

/// Bottom sheet that primes the user with product rationale before
/// requesting system location permissions.
class LocationPrimingSheet extends StatelessWidget {
  const LocationPrimingSheet({
    super.key,
    this.onEnableLocation,
    this.onEnterManually,
    this.onMaybeLater,
  });

  /// Called when the user taps "Enable Location".
  final VoidCallback? onEnableLocation;

  /// Called when the user taps "Enter Location Manually".
  final VoidCallback? onEnterManually;

  /// Called when the user dismisses via "Maybe Later".
  final VoidCallback? onMaybeLater;

  /// Convenience method to display [LocationPrimingSheet] in a modal sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onEnableLocation,
    VoidCallback? onEnterManually,
    VoidCallback? onMaybeLater,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return LocationPrimingSheet(
          onEnableLocation: () {
            Navigator.of(sheetContext).pop();
            onEnableLocation?.call();
          },
          onEnterManually: () {
            Navigator.of(sheetContext).pop();
            onEnterManually?.call();
          },
          onMaybeLater: () {
            Navigator.of(sheetContext).pop();
            onMaybeLater?.call();
          },
        );
      },
    );
  }

  void _handleEnable(BuildContext context) {
    if (onEnableLocation != null) {
      onEnableLocation!.call();
    } else {
      unawaited(
        context.read<LocationCubit>().requestPermissionFromPriming(),
      );
    }
  }

  void _handleManual(BuildContext context) {
    if (onEnterManually != null) {
      onEnterManually!.call();
    } else {
      unawaited(
        context.read<LocationCubit>().enterLocationManuallyFromPriming(),
      );
    }
  }

  void _handleMaybeLater(BuildContext context) {
    if (onMaybeLater != null) {
      onMaybeLater!.call();
    } else {
      context.read<LocationCubit>().dismissPriming();
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
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: CaliforniaColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Location Icon Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: CaliforniaColors.brandTertiary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.location_solid,
                  size: 36,
                  color: CaliforniaColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Find Hotels Near You',
                style: CaliforniaTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Copy explaining why location is needed
              Text(
                'Hotelyn uses your location to discover hotels nearby, '
                'calculate accurate travel distance, and recommend '
                'local stays for your journey.',
                style: CaliforniaTypography.p14Regular.copyWith(
                  color: CaliforniaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Value propositions
              const _BenefitItem(
                icon: CupertinoIcons.map_pin_ellipse,
                title: 'Accurate Distance',
                description: 'See the exact distance and travel time to hotels',
              ),
              const SizedBox(height: 16),
              const _BenefitItem(
                icon: CupertinoIcons.compass,
                title: 'Local Recommendations',
                description: 'Explore top-rated stays in your current area',
              ),
              const SizedBox(height: 16),
              const _BenefitItem(
                icon: CupertinoIcons.shield_lefthalf_fill,
                title: 'Your Privacy Matters',
                description: 'Location is only used when the app is active',
              ),
              const SizedBox(height: 32),

              // Primary Action: Enable Location
              CaliforniaButton.primary(
                label: 'Enable Location',
                onPressed: () => _handleEnable(context),
              ),
              const SizedBox(height: 12),

              // Secondary Action: Enter Manually
              CaliforniaButton.ghost(
                label: 'Enter Location Manually',
                onPressed: () => _handleManual(context),
              ),
              const SizedBox(height: 8),

              // Tertiary Action: Maybe Later
              CaliforniaButton.ghost(
                label: 'Maybe Later',
                height: 40,
                onPressed: () => _handleMaybeLater(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CaliforniaColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: CaliforniaColors.brandPrimary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CaliforniaTypography.h5),
              Text(
                description,
                style: CaliforniaTypography.p12Regular.copyWith(
                  color: CaliforniaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
