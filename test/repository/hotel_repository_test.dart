import 'dart:io';

import 'package:buscatelo/data/network/hotel_api.dart';
import 'package:buscatelo/data/repository/hotel_repository.dart';
import 'package:buscatelo/data/repository/remote_hotel_repository.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../bloc/mock_hotel_repository.dart';
import '../dependecies.dart';

class MockApi extends Mock implements HotelApi {}

void main() {
  group('Hotel repository tests::', () {
    late HotelApi _api;
    late HotelRepository _hotelRepository;

    setupTestDependencies();

    setUpAll(() {
      _api = MockApi();
      _hotelRepository = RemoteHotelRepository(_api);
    });

    test(
      'When fetchHotels success, then return a list of $HotelModel',
      () async {
        // Setup
        final mockResponse = Future.value(MockHotelRepository.hotels);
        when(() => _api.getHotels()).thenAnswer((_) => mockResponse);

        // Execution
        final response = await _hotelRepository.fetchHotels();

        // Expect
        expect(response, isNotNull);
        expect(response.length, MockHotelRepository.hotels.length);
      },
    );

    test(
      'When fetchHotelDetail success, then return an $HotelModel',
      () async {
        // Setup
        final mockResponse = Future.value(MockHotelRepository.hotels);
        when(() => _api.getHotels()).thenAnswer((_) => mockResponse);

        // Execution
        final response = await _hotelRepository.fetchHotelDetail('ArtHouse');

        // Expect
        expect(response, isNotNull);
        expect(response.price, 10);
      },
    );

    test(
      'When fetchHotels fails by invalid JSON format, then throw an $FormatException',
      () async {
        // Setup
        when(() => _api.getHotels())
            .thenThrow(const FormatException('Something goes wrong'));

        // Expect

        expect(() => _hotelRepository.fetchHotels(), throwsA(isA<Exception>()));
        verify(() => _api.getHotels());
      },
    );

    test(
      'When fetchHotels fails by wrong internet connection, then throw an $SocketException',
      () async {
        // Setup
        when(() => _api.getHotels())
            .thenThrow(const SocketException('Something goes wrong'));

        // Expect

        expect(() => _hotelRepository.fetchHotels(), throwsA(isA<Exception>()));
        verify(() => _api.getHotels());
      },
    );

    test(
      'When fetchHotels fails by server error, then throw an $HttpException',
      () async {
        // Setup
        when(() => _api.getHotels())
            .thenThrow(const HttpException('Something goes wrong'));

        // Expect

        expect(() => _hotelRepository.fetchHotels(), throwsA(isA<Exception>()));
        verify(() => _api.getHotels());
      },
    );
  });
}
