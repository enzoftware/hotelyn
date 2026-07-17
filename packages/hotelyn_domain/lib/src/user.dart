import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// The app-specific role attached to a user's profile, mirroring the Postgres
/// `user_role` enum.
///
/// Identity lives in Supabase's `auth.users`; this role (and hotel ownership)
/// lives on the linked `profiles` row (BE-101). A [hotelStaff] user is expected
/// to carry a [User.hotelId]; [guest] and [admin] never do.
enum UserRole {
  @JsonValue('guest')
  guest,
  @JsonValue('hotel_staff')
  hotelStaff,
  @JsonValue('admin')
  admin,
}

/// A user of Hotelyn — the app-side view of a `profiles` row (BE-101).
///
/// Models the *problem* (who this person is and what they can do), not the row:
/// [role] is an enum and construction rejects a [UserRole.hotelStaff] with no
/// [hotelId]. Identity attributes that live on `auth.users` (email, phone) are
/// deliberately not part of this entity.
///
/// JSON keys are snake_case to match the REST API / Postgres row shape
/// (`full_name`, `hotel_id`, …).
@JsonSerializable(fieldRename: FieldRename.snake)
class User extends Equatable {
  User({
    required this.id,
    required this.role,
    this.fullName,
    this.hotelId,
  }) {
    // A hotel_staff profile is scoped to exactly one hotel; guests and admins
    // never carry a hotel (BE-101 `profiles.hotel_id`). Enforce both
    // directions so a decoded row can neither let a staff member act with no
    // hotel scope nor attach a stray hotel to a guest/admin.
    //
    // This is an unconditional throw, not an `assert`: the entity decodes
    // backend JSON and the guard must hold in release builds too, where asserts
    // are stripped.
    final hasHotel = hotelId != null;
    if ((role == UserRole.hotelStaff) != hasHotel) {
      throw ArgumentError(
        'hotelId must be set for hotelStaff users and null otherwise',
      );
    }
  }

  /// Decodes a `User` from a REST/RPC JSON row.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// The user's id — the same uuid as the linked `auth.users` row.
  final String id;

  /// The app-specific role controlling what this user can do.
  final UserRole role;

  /// Display name, when the profile carries one. `null` if unset.
  final String? fullName;

  /// The hotel this user works for. Set for [UserRole.hotelStaff]; `null` for
  /// guests and admins.
  final String? hotelId;

  /// Encodes this `User` to a snake_case JSON map.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        role,
        fullName,
        hotelId,
      ];
}
