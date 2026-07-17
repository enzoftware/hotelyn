import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

// User is the app-side view of a `profiles` row (BE-101). These pin the
// snake_case row shape, the user_role enum mapping, and the construction-time
// invariant that a hotel_staff user is scoped to a hotel.
void main() {
  group('User', () {
    test('supports value equality', () {
      final a = User(id: 'u1', role: UserRole.guest, fullName: 'Ada');
      final b = User(id: 'u1', role: UserRole.guest, fullName: 'Ada');
      expect(a, equals(b));
    });

    test('differs when the role differs', () {
      final guest = User(id: 'u1', role: UserRole.guest);
      final admin = User(id: 'u1', role: UserRole.admin);
      expect(guest, isNot(equals(admin)));
    });

    test('leaves fullName and hotelId null by default', () {
      final user = User(id: 'u1', role: UserRole.guest);
      expect(user.fullName, isNull);
      expect(user.hotelId, isNull);
    });

    group('fromJson', () {
      test('decodes a guest profile row', () {
        final user = User.fromJson(const {
          'id': 'u1',
          'role': 'guest',
          'full_name': 'Ada Lovelace',
          'hotel_id': null,
        });

        expect(user.id, 'u1');
        expect(user.role, UserRole.guest);
        expect(user.fullName, 'Ada Lovelace');
        expect(user.hotelId, isNull);
      });

      test('maps the hotel_staff role from its snake_case JSON value', () {
        final user = User.fromJson(const {
          'id': 'u2',
          'role': 'hotel_staff',
          'hotel_id': 'h1',
        });

        expect(user.role, UserRole.hotelStaff);
        expect(user.hotelId, 'h1');
      });

      test('decodes each user_role enum value', () {
        User withRole(String role, {String? hotelId}) => User.fromJson({
              'id': 'u1',
              'role': role,
              if (hotelId != null) 'hotel_id': hotelId,
            });

        expect(withRole('guest').role, UserRole.guest);
        expect(
          withRole('hotel_staff', hotelId: 'h1').role,
          UserRole.hotelStaff,
        );
        expect(withRole('admin').role, UserRole.admin);
      });

      test('tolerates a missing full_name', () {
        final user = User.fromJson(const {'id': 'u1', 'role': 'guest'});
        expect(user.fullName, isNull);
      });
    });

    group('construction invariant', () {
      test('rejects a hotel_staff user with no hotelId (via fromJson)', () {
        expect(
          () => User.fromJson(const {'id': 'u2', 'role': 'hotel_staff'}),
          throwsArgumentError,
        );
      });

      test('rejects a directly-constructed hotel_staff with no hotelId', () {
        // A runtime throw (not an assert), so it also fires in release builds.
        expect(
          () => User(id: 'u2', role: UserRole.hotelStaff),
          throwsArgumentError,
        );
      });

      test('rejects a guest that carries a hotelId', () {
        expect(
          () => User.fromJson(const {
            'id': 'u1',
            'role': 'guest',
            'hotel_id': 'h1',
          }),
          throwsArgumentError,
        );
      });

      test('rejects an admin that carries a hotelId', () {
        expect(
          () => User(id: 'u3', role: UserRole.admin, hotelId: 'h1'),
          throwsArgumentError,
        );
      });

      test('accepts a hotel_staff user that carries a hotelId', () {
        expect(
          () => User.fromJson(const {
            'id': 'u2',
            'role': 'hotel_staff',
            'hotel_id': 'h1',
          }),
          returnsNormally,
        );
      });

      test('allows guests and admins with no hotelId', () {
        expect(
          () => User.fromJson(const {'id': 'u1', 'role': 'guest'}),
          returnsNormally,
        );
        expect(
          () => User.fromJson(const {'id': 'u3', 'role': 'admin'}),
          returnsNormally,
        );
      });
    });

    test('round-trips a hotel_staff profile through toJson/fromJson', () {
      final user = User(
        id: 'u2',
        role: UserRole.hotelStaff,
        fullName: 'Grace Hopper',
        hotelId: 'h1',
      );

      final json = user.toJson();
      expect(json['role'], 'hotel_staff');
      expect(json['full_name'], 'Grace Hopper');
      expect(json['hotel_id'], 'h1');
      expect(User.fromJson(json), equals(user));
    });
  });
}
