import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

// StaffRoom decodes a staff_room_list / set_room_availability RPC row (BE-501).
void main() {
  group('StaffRoom.fromJson', () {
    StaffRoom withStatus(String status) => StaffRoom.fromJson({
          'id': 'r1',
          'hotel_id': 'h1',
          'name': '101',
          'room_type': 'double',
          'capacity': 2,
          'price_per_night': 180.0,
          'is_available': true,
          'status': status,
        });

    test('maps a full row', () {
      final room = withStatus('available');
      expect(room.id, 'r1');
      expect(room.hotelId, 'h1');
      expect(room.roomType, 'double');
      expect(room.capacity, 2);
      expect(room.pricePerNight, 180.0);
      expect(room.isAvailable, isTrue);
      expect(room.status, RoomStatus.available);
    });

    test('decodes each derived status value', () {
      expect(withStatus('available').status, RoomStatus.available);
      expect(withStatus('unavailable').status, RoomStatus.unavailable);
      expect(withStatus('held').status, RoomStatus.held);
      expect(withStatus('occupied').status, RoomStatus.occupied);
    });

    test('coerces an integer price into a double', () {
      final room = StaffRoom.fromJson(const {
        'id': 'r1',
        'hotel_id': 'h1',
        'name': '101',
        'room_type': 'double',
        'capacity': 2,
        'price_per_night': 180,
        'is_available': true,
        'status': 'available',
      });
      expect(room.pricePerNight, 180.0);
    });

    test('supports value equality', () {
      expect(withStatus('held'), equals(withStatus('held')));
      expect(withStatus('held'), isNot(equals(withStatus('occupied'))));
    });
  });
}
