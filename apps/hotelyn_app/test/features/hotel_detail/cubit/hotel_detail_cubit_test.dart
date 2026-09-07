import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/features/hotel_detail/hotel_detail.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';

class MockHotelynApiClient extends Mock implements HotelynApiClient {}

void main() {
  group('HotelDetailCubit', () {
    late MockHotelynApiClient apiClient;
    const testHotel = domain.Hotel(
      id: 'hotel-1',
      name: 'Diamond Heart Hotel',
      city: 'Purwokerto',
      country: 'Indonesia',
      description: 'A great place to stay',
    );

    const testRoomAvailable = domain.Room(
      id: 'room-1',
      hotelId: 'hotel-1',
      name: 'Deluxe Suite',
      roomType: 'deluxe',
      capacity: 2,
      pricePerNight: 46,
      isAvailable: true,
      availableNow: true,
    );

    const testRoomUnavailable = domain.Room(
      id: 'room-2',
      hotelId: 'hotel-1',
      name: 'Standard Room',
      roomType: 'standard',
      capacity: 2,
      pricePerNight: 35,
      isAvailable: true,
      availableNow: false,
    );

    setUp(() {
      apiClient = MockHotelynApiClient();
    });

    test('initial state has status initial and hasAvailableRoom true', () {
      final cubit = HotelDetailCubit(
        hotel: testHotel,
        apiClient: apiClient,
      );
      expect(cubit.state.status, equals(HotelDetailStatus.initial));
      expect(cubit.state.hasAvailableRoom, isTrue);
      expect(cubit.state.rooms, isEmpty);
    });

    blocTest<HotelDetailCubit, HotelDetailState>(
      'checkAvailability emits loaded with hasAvailableRoom true '
      'when room is available now',
      build: () {
        when(
          () => apiClient.getRooms(hotelId: 'hotel-1'),
        ).thenAnswer((_) async => [testRoomAvailable]);
        return HotelDetailCubit(
          hotel: testHotel,
          apiClient: apiClient,
        );
      },
      act: (cubit) => cubit.checkAvailability(),
      expect: () => [
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loading,
        ),
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loaded,
          rooms: [testRoomAvailable],
        ),
      ],
    );

    blocTest<HotelDetailCubit, HotelDetailState>(
      'checkAvailability emits loaded with hasAvailableRoom false '
      'when all rooms are unavailable now',
      build: () {
        when(
          () => apiClient.getRooms(hotelId: 'hotel-1'),
        ).thenAnswer((_) async => [testRoomUnavailable]);
        return HotelDetailCubit(
          hotel: testHotel,
          apiClient: apiClient,
        );
      },
      act: (cubit) => cubit.checkAvailability(),
      expect: () => [
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loading,
        ),
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loaded,
          rooms: [testRoomUnavailable],
          hasAvailableRoom: false,
        ),
      ],
    );

    blocTest<HotelDetailCubit, HotelDetailState>(
      'checkAvailability handles ApiException gracefully with fallback',
      build: () {
        when(
          () => apiClient.getRooms(hotelId: 'hotel-1'),
        ).thenThrow(const ApiException('Server error'));
        return HotelDetailCubit(
          hotel: testHotel,
          apiClient: apiClient,
        );
      },
      act: (cubit) => cubit.checkAvailability(),
      expect: () => [
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loading,
        ),
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loaded,
        ),
      ],
    );

    blocTest<HotelDetailCubit, HotelDetailState>(
      'checkAvailability handles generic exception with failure status',
      build: () {
        when(
          () => apiClient.getRooms(hotelId: 'hotel-1'),
        ).thenThrow(Exception('Unexpected error'));
        return HotelDetailCubit(
          hotel: testHotel,
          apiClient: apiClient,
        );
      },
      act: (cubit) => cubit.checkAvailability(),
      expect: () => [
        const HotelDetailState(
          hotel: testHotel,
          status: HotelDetailStatus.loading,
        ),
        isA<HotelDetailState>()
            .having((s) => s.status, 'status', HotelDetailStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Unexpected error'),
            ),
      ],
    );
  });
}
