import 'package:bordered_text/bordered_text.dart';
import 'package:buscatelo/model/room_model.dart';
import 'package:flutter/material.dart';

class RoomItem extends StatelessWidget {
  final Room room;

  const RoomItem({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.network(
              room.imageUrl!,
              fit: BoxFit.fitWidth,
              height: 160,
              width: 400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(8),
          ),
          Center(
            child: BorderedText(
              strokeWidth: 2.0,
              strokeColor: Colors.black,
              child: Text(
                room.name!,
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
    );
  }
}

// Card(
//         semanticContainer: true,
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         child: Stack(
//           
//           children: <Widget>[
            
            
//           ],
//         ),
//         
//         
//       ),
//     );