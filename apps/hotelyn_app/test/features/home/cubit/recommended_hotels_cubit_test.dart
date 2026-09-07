import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/home/cubit/recommended_hotels_cubit.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class _MockHotelRepository extends Mock implements domain.HotelRepository {}

void main() {
  late _MockHotelRepository mockRepository;

  setUp(() {
    mockRepository = _MockHotelRepository();
  });

  const testHotels = <domain.Hotel>[
    domain.Hotel(id: '1', name: 'Hotel A', city: 'Bali', country: 'Indonesia'),
    domain.Hotel(
      id: '2',
      name: 'Hotel B',
      city: 'Jakarta',
      country: 'Indonesia',
    ),
  ];

  group('RecommendedHotelsCubit', () {
    test('initial state is RecommendedHotelsInitial', () async {
      final cubit = RecommendedHotelsCubit(hotelRepository: mockRepository);
      expect(cubit.state, isA<RecommendedHotelsInitial>());
      await cubit.close();
    });

    blocTest<RecommendedHotelsCubit, RecommendedHotelsState>(
      'emits [Loading, Loaded] when repository returns hotels',
      setUp: () {
        when(
          () => mockRepository.recommendedHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => testHotels);
      },
      build: () => RecommendedHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadRecommendedHotels(
        latitude: -7.4243,
        longitude: 109.2391,
      ),
      expect: () => [
        isA<RecommendedHotelsLoading>(),
        isA<RecommendedHotelsLoaded>()
            .having((s) => s.hotels, 'hotels', testHotels)
            .having((s) => s.isFallback, 'isFallback', false),
      ],
    );

    blocTest<RecommendedHotelsCubit, RecommendedHotelsState>(
      'emits [Loading, Loaded] with empty list when repository returns empty',
      setUp: () {
        when(
          () => mockRepository.recommendedHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenAnswer((_) async => <domain.Hotel>[]);
      },
      build: () => RecommendedHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadRecommendedHotels(
        latitude: -7.4243,
        longitude: 109.2391,
      ),
      expect: () => [
        isA<RecommendedHotelsLoading>(),
        isA<RecommendedHotelsLoaded>().having(
          (s) => s.hotels,
          'hotels',
          isEmpty,
        ),
      ],
    );

    blocTest<RecommendedHotelsCubit, RecommendedHotelsState>(
      'emits [Loading, Failure] when repository throws',
      setUp: () {
        when(
          () => mockRepository.recommendedHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: any(named: 'radiusKm'),
          ),
        ).thenThrow(Exception('Network error'));
      },
      build: () => RecommendedHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadRecommendedHotels(
        latitude: -7.4243,
        longitude: 109.2391,
      ),
      expect: () => [
        isA<RecommendedHotelsLoading>(),
        isA<RecommendedHotelsFailure>().having(
          (s) => s.message,
          'message',
          contains('Network error'),
        ),
      ],
    );

    blocTest<RecommendedHotelsCubit, RecommendedHotelsState>(
      'passes custom radiusKm to repository',
      setUp: () {
        when(
          () => mockRepository.recommendedHotels(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radiusKm: 100,
          ),
        ).thenAnswer((_) async => testHotels);
      },
      build: () => RecommendedHotelsCubit(hotelRepository: mockRepository),
      act: (cubit) => cubit.loadRecommendedHotels(
        latitude: -7.4243,
        longitude: 109.2391,
        radiusKm: 100,
      ),
      verify: (_) {
        verify(
          () => mockRepository.recommendedHotels(
            latitude: -7.4243,
            longitude: 109.2391,
            radiusKm: 100,
          ),
        ).called(1);
      },
    );
  });
}
