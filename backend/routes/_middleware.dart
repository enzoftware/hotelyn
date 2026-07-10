import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:supabase/supabase.dart';

HotelDataClient? _dataClient;
AuthClient? _authClient;

String _supabaseUrl() =>
    Platform.environment['SUPABASE_URL'] ?? 'http://127.0.0.1:54321';

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
    SupabaseClient(_supabaseUrl(), serviceRoleKey),
  );
}

/// Builds the Supabase Auth client from the environment, once.
///
/// Auth runs with the ANON key (a public, signed-out flow), never the
/// service-role key — the service role would bypass GoTrue's rate limits and
/// user checks. Required explicitly for the same fail-fast reason as above.
///
/// The GoTrue client uses the IMPLICIT flow: this server is stateless and has
/// no async storage, and PKCE would try to persist a code verifier (and crash
/// with a null-check). We only need GoTrue to send/verify codes and return
/// tokens, not to hold session state, so implicit suits the server side.
AuthClient _resolveAuthClient() {
  final anonKey = Platform.environment['SUPABASE_ANON_KEY'];
  if (anonKey == null || anonKey.isEmpty) {
    throw StateError(
      'SUPABASE_ANON_KEY must be set to a valid anon key '
      '(see `supabase status`).',
    );
  }
  return _authClient ??= SupabaseAuthClient(
    GoTrueClient(
      url: '${_supabaseUrl()}/auth/v1',
      headers: {'apikey': anonKey, 'Authorization': 'Bearer $anonKey'},
      autoRefreshToken: false,
      flowType: AuthFlowType.implicit,
    ),
  );
}

Handler middleware(Handler handler) {
  return handler
      .use(provider<HotelDataClient>((_) => _resolveDataClient()))
      .use(provider<AuthClient>((_) => _resolveAuthClient()));
}
