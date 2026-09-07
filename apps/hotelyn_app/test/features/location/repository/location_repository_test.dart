import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/core/data/storage/storage.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mocks.dart';

void main() {
  group('LocationRepository', () {
    late SharedStorage sharedStorage;
    late LocationService locationService;
    late LocationRepository repository;

    const mockLocation = UserLocation(
      latitude: -6.2088,
      longitude: 106.8456,
      cityName: 'Jakarta, IND',
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      locationService = MockLocationService();
    });

    test(
      'getPermissionStatus reconciles stored status with operating system',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedStorage.locationPermissionKey: 'denied',
        });
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        when(() => locationService.checkPermission()).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );

        final status = await repository.getPermissionStatus();
        expect(status, LocationPermissionStatus.granted);
        expect(
          sharedStorage.getLocationPermissionStatus(),
          LocationPermissionStatus.granted,
        );
        verify(() => locationService.checkPermission()).called(1);
      },
    );

    test(
      'getPermissionStatus preserves primed when system is unknown',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedStorage.locationPermissionKey: 'primed',
        });
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        when(() => locationService.checkPermission()).thenAnswer(
          (_) async => LocationPermissionStatus.unknown,
        );

        final status = await repository.getPermissionStatus();
        expect(status, LocationPermissionStatus.primed);
      },
    );

    test('getPermissionStatus checks service if no status stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sharedStorage = SharedStorage(sharedPreferences: prefs);
      repository = LocationRepository(
        sharedStorage: sharedStorage,
        locationService: locationService,
      );

      when(() => locationService.checkPermission()).thenAnswer(
        (_) async => LocationPermissionStatus.denied,
      );

      final status = await repository.getPermissionStatus();
      expect(status, LocationPermissionStatus.denied);
      expect(
        sharedStorage.getLocationPermissionStatus(),
        LocationPermissionStatus.denied,
      );
    });

    test('markAsPrimed sets primed status in storage', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sharedStorage = SharedStorage(sharedPreferences: prefs);
      repository = LocationRepository(
        sharedStorage: sharedStorage,
        locationService: locationService,
      );

      await repository.markAsPrimed();
      expect(
        sharedStorage.getLocationPermissionStatus(),
        LocationPermissionStatus.primed,
      );
    });

    test(
      'requestPermission (granted) stores granted status and location',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        when(() => locationService.requestPermission()).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        when(() => locationService.getCurrentLocation()).thenAnswer(
          (_) async => mockLocation,
        );

        final result = await repository.requestPermission();
        expect(result.status, LocationPermissionStatus.granted);
        expect(result.location, mockLocation);
        expect(
          sharedStorage.getLocationPermissionStatus(),
          LocationPermissionStatus.granted,
        );
        expect(sharedStorage.getUserLocation(), mockLocation);
      },
    );

    test(
      'requestPermission (granted) preserves defaultFallback when acquired '
      'is null',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        when(() => locationService.requestPermission()).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        when(() => locationService.getCurrentLocation()).thenAnswer(
          (_) async => null,
        );

        final result = await repository.requestPermission();
        expect(result.status, LocationPermissionStatus.granted);
        expect(result.location, UserLocation.defaultFallback);
        expect(result.location.isManualFallback, isTrue);
      },
    );

    test(
      'requestPermission (denied) stores denied status and fallback',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        when(() => locationService.requestPermission()).thenAnswer(
          (_) async => LocationPermissionStatus.denied,
        );

        final result = await repository.requestPermission();
        expect(result.status, LocationPermissionStatus.denied);
        expect(result.location, UserLocation.defaultFallback);
        expect(
          sharedStorage.getLocationPermissionStatus(),
          LocationPermissionStatus.denied,
        );
        expect(sharedStorage.getUserLocation(), UserLocation.defaultFallback);
      },
    );

    test('getLocation returns defaultFallback when empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      sharedStorage = SharedStorage(sharedPreferences: prefs);
      repository = LocationRepository(
        sharedStorage: sharedStorage,
        locationService: locationService,
      );

      final location = await repository.getLocation();
      expect(location, UserLocation.defaultFallback);
      expect(sharedStorage.getUserLocation(), UserLocation.defaultFallback);
    });

    test(
      'getLocation returns defaultFallback when stored data is malformed json',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedStorage.userLocationKey: '{malformed_json',
        });
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        final location = await repository.getLocation();
        expect(location, UserLocation.defaultFallback);
      },
    );

    test(
      'getLocation returns defaultFallback when stored data is non-map',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedStorage.userLocationKey: '[1, 2, 3]',
        });
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        final location = await repository.getLocation();
        expect(location, UserLocation.defaultFallback);
      },
    );

    test(
      'SharedStorage.getUserLocation returns null on invalid field types '
      'without throwing TypeError',
      () async {
        SharedPreferences.setMockInitialValues({
          SharedStorage.userLocationKey: '{"latitude": "invalid_type"}',
        });
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);

        expect(sharedStorage.getUserLocation(), isNull);
      },
    );

    test(
      'setManualLocation persists chosen location with isManualFallback = true',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        sharedStorage = SharedStorage(sharedPreferences: prefs);
        repository = LocationRepository(
          sharedStorage: sharedStorage,
          locationService: locationService,
        );

        const custom = UserLocation(
          latitude: -8.4095,
          longitude: 115.1889,
          cityName: 'Bali, IND',
        );

        final result = await repository.setManualLocation(location: custom);
        expect(result.cityName, 'Bali, IND');
        expect(result.isManualFallback, isTrue);
        expect(sharedStorage.getUserLocation()?.isManualFallback, isTrue);
      },
    );
  });
}
