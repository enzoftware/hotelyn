import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/room_model.dart';

class RoomItem extends StatelessWidget {
  const RoomItem({Key? key, required this.room}) : super(key: key);

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 5,
          margin: const EdgeInsets.all(8),
          child: Image.network(
            room.imageUrl!,
            fit: BoxFit.fitWidth,
            height: 160,
            width: 400,
          ),
        ),
        Center(
          child: BorderedText(
            strokeWidth: 2,
            strokeColor: Colors.black,
            child: Text(
              room.name!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
