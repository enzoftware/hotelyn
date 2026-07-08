import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:supabase/supabase.dart';

HotelDataClient? _dataClient;

/// Builds the Supabase-backed data client from the environment, once.
///
/// The server talks to Supabase with the service-role key; that key never
/// reaches a Flutter client. `SUPABASE_URL` falls back to the local-stack
/// default, but the service-role key must be provided explicitly (copy it from
/// `supabase status`) — defaulting it would silently hide a misconfiguration,
/// and every query would then fail at request time instead.
HotelDataClient _resolveDataClient() {
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (serviceRoleKey == null || serviceRoleKey.isEmpty) {
    throw StateError(
      'SUPABASE_SERVICE_ROLE_KEY must be set to a valid service-role key '
      '(see `supabase status`).',
    );
  }
  return _dataClient ??= SupabaseHotelDataClient(
    SupabaseClient(
      Platform.environment['SUPABASE_URL'] ?? 'http://127.0.0.1:54321',
      serviceRoleKey,
    ),
  );
}

Handler middleware(Handler handler) {
  return handler.use(
    provider<HotelDataClient>((_) => _resolveDataClient()),
  );
}
