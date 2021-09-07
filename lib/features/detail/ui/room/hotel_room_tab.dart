import 'package:buscatelo/model/room_model.dart';
import 'package:flutter/material.dart';

import 'room_item.dart';

class HotelRoomTab extends StatelessWidget {
  final List<Room>? rooms;
  const HotelRoomTab({
    Key? key,
    this.rooms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms!.length,
      itemBuilder: (context, index) => RoomItem(room: rooms![index]),
    );
  }
}
