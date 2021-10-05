import 'package:flutter/material.dart';
import 'package:hotel_booking_app/features/detail/ui/room/room_item.dart';
import 'package:hotel_booking_app/model/room_model.dart';

class HotelRoomTab extends StatelessWidget {
  const HotelRoomTab({
    Key? key,
    this.rooms,
  }) : super(key: key);

  final List<Room>? rooms;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms!.length,
      itemBuilder: (context, index) => RoomItem(room: rooms![index]),
    );
  }
}
