import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('LocationCubit', () {
    late LocationRepository locationRepository;

    const mockGrantedLocation = UserLocation(
      latitude: -12.0464,
      longitude: -77.0428,
      cityName: 'Lima, PER',
    );

    setUpAll(() {
      registerFallbackValue(LocationPermissionStatus.unknown);
      registerFallbackValue(UserLocation.defaultFallback);
    });

    setUp(() {
      locationRepository = MockLocationRepository();
    });

    test('initial state has correct default values', () {
      final cubit = LocationCubit(locationRepository: locationRepository);
      expect(cubit.state.permissionStatus, LocationPermissionStatus.unknown);
      expect(cubit.state.userLocation, UserLocation.defaultFallback);
      expect(cubit.state.isPrimingSheetVisible, isFalse);
      expect(cubit.state.isManualLocationDialogOpen, isFalse);
      expect(cubit.state.isLoading, isFalse);
    });

    group('loadLocation', () {
      blocTest<LocationCubit, LocationState>(
        'emits loaded status and location from repository',
        setUp: () {
          when(() => locationRepository.getPermissionStatus()).thenAnswer(
            (_) async => LocationPermissionStatus.granted,
          );
          when(() => locationRepository.getLocation()).thenAnswer(
            (_) async => mockGrantedLocation,
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        act: (cubit) => cubit.loadLocation(),
        expect: () => [
          const LocationState(isLoading: true),
          const LocationState(
            permissionStatus: LocationPermissionStatus.granted,
            userLocation: mockGrantedLocation,
          ),
        ],
      );

      blocTest<LocationCubit, LocationState>(
        'emits errorMessage when repository throws',
        setUp: () {
          when(() => locationRepository.getPermissionStatus()).thenThrow(
            Exception('Storage read failure'),
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        act: (cubit) => cubit.loadLocation(),
        expect: () => [
          const LocationState(isLoading: true),
          isA<LocationState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Storage read failure'),
              ),
        ],
      );
    });

    group('triggerPriming', () {
      blocTest<LocationCubit, LocationState>(
        'marks as primed and shows sheet when status is not granted',
        setUp: () {
          when(() => locationRepository.markAsPrimed()).thenAnswer(
            (_) async {},
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        act: (cubit) => cubit.triggerPriming(),
        expect: () => [
          const LocationState(
            isPrimingSheetVisible: true,
            permissionStatus: LocationPermissionStatus.primed,
          ),
        ],
        verify: (_) {
          verify(() => locationRepository.markAsPrimed()).called(1);
        },
      );

      blocTest<LocationCubit, LocationState>(
        'does not show priming sheet if permission is already granted',
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(
          permissionStatus: LocationPermissionStatus.granted,
        ),
        act: (cubit) => cubit.triggerPriming(),
        expect: () => <LocationState>[],
        verify: (_) {
          verifyNever(() => locationRepository.markAsPrimed());
        },
      );
    });

    group('dismissPriming', () {
      blocTest<LocationCubit, LocationState>(
        'hides priming sheet',
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(isPrimingSheetVisible: true),
        act: (cubit) => cubit.dismissPriming(),
        expect: () => [
          const LocationState(),
        ],
      );
    });

    group('requestPermissionFromPriming', () {
      blocTest<LocationCubit, LocationState>(
        'granted flow: hides sheet, requests permission, emits granted',
        setUp: () {
          when(() => locationRepository.requestPermission()).thenAnswer(
            (_) async => (
              status: LocationPermissionStatus.granted,
              location: mockGrantedLocation,
            ),
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(isPrimingSheetVisible: true),
        act: (cubit) => cubit.requestPermissionFromPriming(),
        expect: () => [
          const LocationState(
            isLoading: true,
          ),
          const LocationState(
            permissionStatus: LocationPermissionStatus.granted,
            userLocation: mockGrantedLocation,
          ),
        ],
      );

      blocTest<LocationCubit, LocationState>(
        'denied flow: emits denied and opens manual location fallback',
        setUp: () {
          when(() => locationRepository.requestPermission()).thenAnswer(
            (_) async => (
              status: LocationPermissionStatus.denied,
              location: UserLocation.defaultFallback,
            ),
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(isPrimingSheetVisible: true),
        act: (cubit) => cubit.requestPermissionFromPriming(),
        expect: () => [
          const LocationState(
            isLoading: true,
          ),
          const LocationState(
            permissionStatus: LocationPermissionStatus.denied,
            isManualLocationDialogOpen: true,
          ),
        ],
      );

      blocTest<LocationCubit, LocationState>(
        'error flow: falls back to manual location and emits error',
        setUp: () {
          when(() => locationRepository.requestPermission()).thenThrow(
            Exception('Hardware error'),
          );
          when(() => locationRepository.setManualLocation()).thenAnswer(
            (_) async => UserLocation.defaultFallback,
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(isPrimingSheetVisible: true),
        act: (cubit) => cubit.requestPermissionFromPriming(),
        expect: () => [
          const LocationState(
            isLoading: true,
          ),
          isA<LocationState>()
              .having(
                (s) => s.permissionStatus,
                'status',
                LocationPermissionStatus.denied,
              )
              .having(
                (s) => s.isManualLocationDialogOpen,
                'isManualLocationDialogOpen',
                true,
              )
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Hardware error'),
              ),
        ],
      );
    });

    group('enterLocationManuallyFromPriming', () {
      blocTest<LocationCubit, LocationState>(
        'dismisses priming, opens manual dialog, saves fallback',
        setUp: () {
          when(() => locationRepository.savePermissionStatus(any()))
              .thenAnswer((_) async {});
          when(() => locationRepository.setManualLocation()).thenAnswer(
            (_) async => UserLocation.defaultFallback,
          );
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(isPrimingSheetVisible: true),
        act: (cubit) => cubit.enterLocationManuallyFromPriming(),
        expect: () => [
          const LocationState(
            isManualLocationDialogOpen: true,
          ),
          const LocationState(
            isManualLocationDialogOpen: true,
            permissionStatus: LocationPermissionStatus.denied,
          ),
        ],
        verify: (_) {
          verify(
            () => locationRepository.savePermissionStatus(
              LocationPermissionStatus.denied,
            ),
          ).called(1);
          verify(() => locationRepository.setManualLocation()).called(1);
        },
      );
    });

    group('setManualLocation', () {
      const customLocation = UserLocation(
        latitude: -8.4095,
        longitude: 115.1889,
        cityName: 'Bali, IND',
        isManualFallback: true,
      );

      blocTest<LocationCubit, LocationState>(
        'saves manual location and closes dialog',
        setUp: () {
          when(
            () => locationRepository.setManualLocation(
              location: customLocation,
            ),
          ).thenAnswer((_) async => customLocation);
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        seed: () => const LocationState(isManualLocationDialogOpen: true),
        act: (cubit) => cubit.setManualLocation(customLocation),
        expect: () => [
          const LocationState(
            isManualLocationDialogOpen: true,
            isLoading: true,
          ),
          const LocationState(
            userLocation: customLocation,
          ),
        ],
      );
    });

    group('selectDefaultFallback', () {
      blocTest<LocationCubit, LocationState>(
        'sets default Purwokerto location',
        setUp: () {
          when(
            () => locationRepository.setManualLocation(
              location: UserLocation.defaultFallback,
            ),
          ).thenAnswer((_) async => UserLocation.defaultFallback);
        },
        build: () => LocationCubit(locationRepository: locationRepository),
        act: (cubit) => cubit.selectDefaultFallback(),
        expect: () => [
          const LocationState(isLoading: true),
          const LocationState(),
        ],
      );
    });

    group('dialog visibility controls', () {
      test('open and close manual location dialog works', () {
        final cubit = LocationCubit(locationRepository: locationRepository);
        expect(cubit.state.isManualLocationDialogOpen, isFalse);

        cubit.openManualLocationDialog();
        expect(cubit.state.isManualLocationDialogOpen, isTrue);

        cubit.closeManualLocationDialog();
        expect(cubit.state.isManualLocationDialogOpen, isFalse);
      });
    });
  });
}
