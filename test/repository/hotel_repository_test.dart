import 'package:buscatelo/data/network/failure_error_handler.dart';
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

    setUp(() {
      _api = getIt<HotelApi>();
      _hotelRepository = RemoteHotelRepository(_api);
    });

    test(
      'When fetchHotels success, then return a list of $HotelModel',
      () async {
        // Setup
        final mockResponse = Future.value(hotels);
        when(() => _api.getHotels()).thenAnswer((_) => mockResponse);

        // Execution
        final response = await _hotelRepository.fetchHotels();

        // Expect
        expect(response, isNotNull);
        expect(response.length, hotels.length);
      },
    );

    // test(
    //   'When fetchHotels fails by invalid JSON format, then throw an $FormatException',
    //   () async {
    //     // Setup
    //     when(() => _api.getHotels()).thenThrow((_) => Exception());

    //     // Execution
    //     final response = await _hotelRepository.fetchHotels();

    //     // Expect
    //     print(response.toString());
    //     expect(response, isNotNull);
    //     print(response.runtimeType);
    //     expect(response, throwsA(isA<Failure>()));
    //   },
    // );
  });
}
