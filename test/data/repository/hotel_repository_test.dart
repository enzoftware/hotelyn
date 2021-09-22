// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/data/network/hotel_api.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/data/repository/remote_hotel_repository.dart';
import 'package:hotel_booking_app/model/models.dart';
import 'package:mocktail/mocktail.dart';

class MockApi extends Mock implements RestClient {}

void main() {
  late HotelRepository repository;
  late RestClient api;
  group('HotelRepository::', () {
    const _hotel = Hotel(
      name: 'fake',
      description: 'fake',
      address: 'fake',
      imageUrl: 'fake',
      reviews: [],
      amenities: [],
      rooms: [],
      price: 0,
    );

    setUp(() {
      api = MockApi();
      repository = RemoteHotelRepository(api);
    });

    test(
      'When fetchHotels is successful, then return a List<Hotel>',
      () async {
        final response = <Hotel>[_hotel];
        when(() => api.getHotels()).thenAnswer((_) async => response);

        final result = await repository.fetchHotels();
        final hotels = result.whenOrNull(success: (data) => data);

        verify(() => api.getHotels());
        expect(hotels?.length, response.length);
      },
    );

    test(
      'When fetchHotels is a failure, then throw an Exception',
      () async {
        when(() => api.getHotels()).thenThrow(Exception());
        expect(await repository.fetchHotels().then((value) => value.whenOrNull(failure: (e) => e)), isA<Exception>());
        verify(() => api.getHotels());
      },
    );

    test(
      'When fetchHotelDetail is successful, then return a Hotel',
      () async {
        final response = <Hotel>[_hotel];
        when(() => api.getHotels()).thenAnswer((_) async => response);

        final result = await repository.fetchHotelDetail(_hotel.name);
        final hotel = result.whenOrNull(success: (data) => data);

        verify(() => api.getHotels());
        expect(hotel?.name, _hotel.name);
      },
    );

    test(
      'When fetchHotelDetail is successful but does not found an hotel, then return an empty Hotel',
      () async {
        const name = 'empty';
        final response = <Hotel>[_hotel];
        when(() => api.getHotels()).thenAnswer((_) async => response);

        final result = await repository.fetchHotelDetail('any');
        final hotel = result.whenOrNull(success: (data) => data);

        verify(() => api.getHotels());
        expect(hotel?.name, name);
      },
    );

    test(
      'When fetchHotelDetail is a failure, then throw an Exception',
          () async {
        when(() => api.getHotels()).thenThrow(Exception());
        expect(await repository.fetchHotelDetail('any').then((value) => value.whenOrNull(failure: (e) => e)), isA<Exception>());
        verify(() => api.getHotels());
      },
    );
  });
}
