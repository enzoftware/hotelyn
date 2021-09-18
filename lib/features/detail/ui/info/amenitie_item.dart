import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/amenitie_model.dart';

class AmenitieItem extends StatelessWidget {
  const AmenitieItem({Key? key, this.amenitie}) : super(key: key);

  final Amenitie? amenitie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
