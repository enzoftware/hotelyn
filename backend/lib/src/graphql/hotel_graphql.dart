import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:graphql_server2/graphql_server2.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/src/data/hotel_data_client.dart';

/// The `Hotel` GraphQL type. Field resolvers read straight off the domain
/// entity; search-only projections (`distanceKm`, `popularity`) are nullable.
GraphQLObjectType _hotelType() {
  return objectType(
    'Hotel',
    fields: [
      field('id', graphQLId, resolve: (obj, _) => (obj as Hotel).id),
      field('name', graphQLString, resolve: (obj, _) => (obj as Hotel).name),
      field(
        'description',
        graphQLString,
        resolve: (obj, _) => (obj as Hotel).description,
      ),
      field(
        'address',
        graphQLString,
        resolve: (obj, _) => (obj as Hotel).address,
      ),
      field('city', graphQLString, resolve: (obj, _) => (obj as Hotel).city),
      field(
        'country',
        graphQLString,
        resolve: (obj, _) => (obj as Hotel).country,
      ),
      field(
        'latitude',
        graphQLFloat,
        resolve: (obj, _) => (obj as Hotel).latitude,
      ),
      field(
        'longitude',
        graphQLFloat,
        resolve: (obj, _) => (obj as Hotel).longitude,
      ),
      field(
        'distanceKm',
        graphQLFloat,
        resolve: (obj, _) => (obj as Hotel).distanceKm,
      ),
      field(
        'popularity',
        graphQLInt,
        resolve: (obj, _) => (obj as Hotel).popularity,
      ),
    ],
  );
}

/// The `Room` GraphQL type.
GraphQLObjectType _roomType() {
  return objectType(
    'Room',
    fields: [
      field('id', graphQLId, resolve: (obj, _) => (obj as Room).id),
      field('hotelId', graphQLId, resolve: (obj, _) => (obj as Room).hotelId),
      field('name', graphQLString, resolve: (obj, _) => (obj as Room).name),
      field(
        'roomType',
        graphQLString,
        resolve: (obj, _) => (obj as Room).roomType,
      ),
      field(
        'capacity',
        graphQLInt,
        resolve: (obj, _) => (obj as Room).capacity,
      ),
      field(
        'pricePerNight',
        graphQLFloat,
        resolve: (obj, _) => (obj as Room).pricePerNight,
      ),
      field(
        'isAvailable',
        graphQLBoolean,
        resolve: (obj, _) => (obj as Room).isAvailable,
      ),
      field(
        'availableNow',
        graphQLBoolean,
        resolve: (obj, _) => (obj as Room).availableNow,
      ),
    ],
  );
}

double _requireDouble(Object? value) => (value! as num).toDouble();

/// Builds the read-only query schema, wiring each query to [client].
GraphQLSchema buildHotelSchema(HotelDataClient client) {
  final hotelType = _hotelType();
  final roomType = _roomType();

  return graphQLSchema(
    queryType: objectType(
      'Query',
      fields: [
        field(
          'nearbyHotels',
          listOf(hotelType),
          inputs: [
            GraphQLFieldInput('lat', graphQLFloat.nonNullable()),
            GraphQLFieldInput('lng', graphQLFloat.nonNullable()),
            GraphQLFieldInput('radiusKm', graphQLFloat.nonNullable()),
          ],
          resolve: (_, args) => client.nearbyHotels(
            lat: _requireDouble(args['lat']),
            lng: _requireDouble(args['lng']),
            radiusKm: _requireDouble(args['radiusKm']),
          ),
        ),
        field(
          'recommendedHotels',
          listOf(hotelType),
          inputs: [
            GraphQLFieldInput('lat', graphQLFloat.nonNullable()),
            GraphQLFieldInput('lng', graphQLFloat.nonNullable()),
            GraphQLFieldInput('radiusKm', graphQLFloat.nonNullable()),
          ],
          resolve: (_, args) => client.recommendedHotels(
            lat: _requireDouble(args['lat']),
            lng: _requireDouble(args['lng']),
            radiusKm: _requireDouble(args['radiusKm']),
          ),
        ),
        field(
          'roomsAvailability',
          listOf(roomType),
          inputs: [
            GraphQLFieldInput('hotelId', graphQLId),
          ],
          resolve: (_, args) =>
              client.roomsAvailability(hotelId: args['hotelId'] as String?),
        ),
      ],
    ),
  );
}

/// Builds a ready-to-execute [GraphQL] instance for [client].
GraphQL buildGraphQL(HotelDataClient client) =>
    GraphQL(buildHotelSchema(client));
