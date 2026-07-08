import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// Single GraphQL endpoint. Accepts a JSON body of the shape
/// `{ "query": "...", "variables": { ... } }` over POST and returns
/// `{ "data": ... }` (or `{ "errors": [...] }` on an invalid query).
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final dynamic body;
  try {
    body = await context.request.json();
  } on FormatException {
    return _badRequest('Request body must be valid JSON.');
  }

  if (body is! Map<String, dynamic> || body['query'] is! String) {
    return _badRequest('Body must be JSON with a "query" string field.');
  }

  final rawVariables = body['variables'];
  if (rawVariables != null && rawVariables is! Map<String, dynamic>) {
    return _badRequest('"variables" must be a JSON object.');
  }

  final query = body['query'] as String;
  final variables = (rawVariables as Map<String, dynamic>?) ?? const {};

  final graphQL = buildGraphQL(context.read<HotelDataClient>());

  try {
    final data =
        await graphQL.parseAndExecute(query, variableValues: variables);
    return Response.json(body: {'data': data});
  } on GraphQLException catch (error) {
    // Invalid query / variables: a client (400) error.
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'errors': error.errors.map((e) => {'message': e.message}).toList(),
      },
    );
  } on Object {
    // Resolver / data-layer failure (e.g. Supabase unreachable): a server error.
    // The internal detail is deliberately not leaked to the client.
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'errors': [
          {'message': 'Unexpected error while executing the query.'},
        ],
      },
    );
  }
}

Response _badRequest(String message) {
  return Response.json(
    statusCode: HttpStatus.badRequest,
    body: {
      'errors': [
        {'message': message},
      ],
    },
  );
}
