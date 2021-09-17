import 'package:hotel_booking_app/model/amenitie_model.dart';
import 'package:flutter/material.dart';

class AmenitieItem extends StatelessWidget {
  final Amenitie? amenitie;

  const AmenitieItem({Key? key, this.amenitie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
            ),
            child: Image.network(
              amenitie!.imageUrl!,
              height: 40,
              width: 40,
            ),
          ),
          Text(amenitie!.name!),
        ],
      ),
    );
  }
}
