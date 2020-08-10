import 'package:bordered_text/bordered_text.dart';
import 'package:buscatelo/model/room_model.dart';
import 'package:flutter/material.dart';

class RoomItem extends StatelessWidget {
  final Room room;

  const RoomItem({Key key, this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(
            room.imageUrl,
            fit: BoxFit.fill,
          ),
          Center(
            child: BorderedText(
              strokeWidth: 4.0,
              strokeColor: Colors.black,
              child: Text(
                room.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(8),
    );
  }
}
