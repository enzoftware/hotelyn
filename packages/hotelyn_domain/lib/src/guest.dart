import 'package:equatable/equatable.dart';

/// A booking guest — the lightweight identity of the person a `Reservation` or
/// `Message` belongs to.
///
/// Distinct from `User` (the full `profiles` view carrying a role and hotel
/// scope): a `Guest` is just who-they-are in a booking context — an id, an
/// optional display name, and an optional contact email. Repository methods
/// that only need to name the guest take/return this, not the richer `User`.
///
/// A pure value type: value equality via [Equatable], no JSON coupling (this is
/// a shared vocabulary contract, not a wire shape).
class Guest extends Equatable {
  const Guest({
    required this.id,
    this.fullName,
    this.email,
  });

  /// The guest's id — the same uuid as their `profiles` / `auth.users` row.
  final String id;

  /// Display name, when known. `null` if the profile carries none.
  final String? fullName;

  /// Contact email, when known. `null` if unavailable in the calling context.
  final String? email;

  @override
  List<Object?> get props => [id, fullName, email];
}
