import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_session.g.dart';

/// The tokens the app persists to stay signed in, plus the authenticated user's
/// id. Returned by the OTP-verify and staff-login endpoints (EPIC-06).
///
/// JSON keys are snake_case to match the REST API shape (`access_token`,
/// `refresh_token`, `user_id`, `expires_in`, `token_type`).
@JsonSerializable(fieldRename: FieldRename.snake)
class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.expiresIn,
    required this.tokenType,
  });

  /// Decodes an `AuthSession` from a REST JSON body.
  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);

  /// The bearer token attached to authenticated requests.
  final String accessToken;

  /// Used to obtain a fresh [accessToken] when it expires.
  final String refreshToken;

  /// The authenticated user's id (Supabase `auth.users.id`).
  final String userId;

  /// Seconds until [accessToken] expires.
  final int expiresIn;

  /// The token scheme (typically `bearer`).
  final String tokenType;

  /// Encodes this `AuthSession` to a snake_case JSON map.
  Map<String, dynamic> toJson() => _$AuthSessionToJson(this);

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        userId,
        expiresIn,
        tokenType,
      ];

  // Never let Equatable's default stringify dump the tokens (it prints every
  // prop in debug builds) — a stray log/print must not leak credentials.
  @override
  bool get stringify => false;

  @override
  String toString() =>
      'AuthSession(userId: $userId, tokenType: $tokenType, '
      'expiresIn: $expiresIn)';
}
