import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/home/cubit/nearby_hotels_cubit.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class _MockHotelRepository extends Mock implements domain.HotelRepository {}

void main() {
  late _MockHotelRepository mockRepository;

  setUp(() {
    mockRepository = _MockHotelRepository();
  });

  const testHotels = <domain.Hotel>[
    domain.Hotel(
      id: 'nearby-1',
      name: 'Cozy Boutique Hotel',
      city: 'Purwokerto',
      country: 'Indonesia',
      distanceKm: 2.4,
    ),
    domain.Hotel(
      id: 'nearby-2',
      name: 'Downtown Suites',
      city: 'Purwokerto',
      country: 'Indonesia',
      distanceKm: 5.1,
    ),
  ];

  group('NearbyHotelsCubit', () {
    test('initial state is NearbyHotelsInitial', () async {
      final cubit = NearbyHotelsCubit(hotelRepository: mockRepository);
      expect(cubit.state, isA<NearbyHotelsInitial>());
      await cubit.close();
    });

    test('uninitialized constructor sets null repository', () async {
      final cubit = NearbyHotelsCubit.uninitialized();
      expect(cubit.hotelRepository, isNull);
      await cubit.loadNearbyHotels(latitude: 0, longitude: 0);
      expect(cubit.state, isA<NearbyHotelsInitial>());
      await cubit.close();
    });

    blocTest<NearbyHotelsCubit, NearbyHotelsState>(
      'emits [Loading, Loaded] when repository returns hotels',
      setUp: () {
        when(
          () => mockRepository.nearbyHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => testHotels);
      },
      build: () => NearbyHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadNearbyHotels(
        latitude: -7.4243,
        longitude: 109.2391,
      ),
      expect: () => [
        isA<NearbyHotelsLoading>(),
        isA<NearbyHotelsLoaded>()
            .having((s) => s.hotels, 'hotels', testHotels)
            .having((s) => s.isFallback, 'isFallback', false),
      ],
    );

    blocTest<NearbyHotelsCubit, NearbyHotelsState>(
      'emits [Loading, Loaded] with empty list when repository returns empty',
      setUp: () {
        when(
          () => mockRepository.nearbyHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => <domain.Hotel>[]);
      },
      build: () => NearbyHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadNearbyHotels(
        latitude: -7.4243,
        longitude: 109.2391,
      ),
      expect: () => [
        isA<NearbyHotelsLoading>(),
        isA<NearbyHotelsLoaded>().having((s) => s.hotels, 'hotels', isEmpty),
      ],
    );

    blocTest<NearbyHotelsCubit, NearbyHotelsState>(
      'emits [Loading, Failure] when repository throws',
      setUp: () {
        when(
          () => mockRepository.nearbyHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenThrow(Exception('Failed to connect'));
      },
      build: () => NearbyHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadNearbyHotels(
        latitude: -7.4243,
        longitude: 109.2391,
      ),
      expect: () => [
        isA<NearbyHotelsLoading>(),
        isA<NearbyHotelsFailure>().having(
          (s) => s.message,
          'message',
          contains('Failed to connect'),
        ),
      ],
    );

    blocTest<NearbyHotelsCubit, NearbyHotelsState>(
      'forwards custom radiusKm to repository',
      setUp: () {
        when(
          () => mockRepository.nearbyHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: 25,
          ),
        ).thenAnswer((_) async => testHotels);
      },
      build: () => NearbyHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadNearbyHotels(
        latitude: -7.4243,
        longitude: 109.2391,
        radiusKm: 25,
      ),
      verify: (_) {
        verify(
          () => mockRepository.nearbyHotels(
            latitude: -7.4243,
            longitude: 109.2391,
            radiusKm: 25,
          ),
        ).called(1);
      },
    );

    test('ignores results from earlier overlapping request', () async {
      final completer1 = Completer<List<domain.Hotel>>();
      final completer2 = Completer<List<domain.Hotel>>();

      when(
        () => mockRepository.nearbyHotels(
          latitude: 1,
          longitude: 1,
          radiusKm: any(named: 'radiusKm'),
        ),
      ).thenAnswer((_) => completer1.future);

      when(
        () => mockRepository.nearbyHotels(
          latitude: 2,
          longitude: 2,
          radiusKm: any(named: 'radiusKm'),
        ),
      ).thenAnswer((_) => completer2.future);

      final cubit = NearbyHotelsCubit(hotelRepository: mockRepository);

      final future1 = cubit.loadNearbyHotels(
        latitude: 1,
        longitude: 1,
      );
      final future2 = cubit.loadNearbyHotels(
        latitude: 2,
        longitude: 2,
      );

      completer2.complete([testHotels[1]]);
      await future2;

      expect(
        cubit.state,
        isA<NearbyHotelsLoaded>().having(
          (s) => s.hotels,
          'hotels',
          [testHotels[1]],
        ),
      );

      // Older request finishes afterwards
      completer1.complete([testHotels[0]]);
      await future1;

      // State remains from the newer request
      expect(
        cubit.state,
        isA<NearbyHotelsLoaded>().having(
          (s) => s.hotels,
          'hotels',
          [testHotels[1]],
        ),
      );

      await cubit.close();
    });

    test('ignores errors from earlier overlapping request', () async {
      final completer1 = Completer<List<domain.Hotel>>();
      final completer2 = Completer<List<domain.Hotel>>();

      when(
        () => mockRepository.nearbyHotels(
          latitude: 1,
          longitude: 1,
          radiusKm: any(named: 'radiusKm'),
        ),
      ).thenAnswer((_) => completer1.future);

      when(
        () => mockRepository.nearbyHotels(
          latitude: 2,
          longitude: 2,
          radiusKm: any(named: 'radiusKm'),
        ),
      ).thenAnswer((_) => completer2.future);

      final cubit = NearbyHotelsCubit(hotelRepository: mockRepository);

      final future1 = cubit.loadNearbyHotels(
        latitude: 1,
        longitude: 1,
      );
      final future2 = cubit.loadNearbyHotels(
        latitude: 2,
        longitude: 2,
      );

      completer2.complete([testHotels[1]]);
      await future2;

      expect(
        cubit.state,
        isA<NearbyHotelsLoaded>().having(
          (s) => s.hotels,
          'hotels',
          [testHotels[1]],
        ),
      );

      // Older request fails afterwards
      completer1.completeError(Exception('Old network error'));
      await future1;

      // State remains loaded from the newer request, not failure
      expect(
        cubit.state,
        isA<NearbyHotelsLoaded>().having(
          (s) => s.hotels,
          'hotels',
          [testHotels[1]],
        ),
      );

      await cubit.close();
    });
  });
}
