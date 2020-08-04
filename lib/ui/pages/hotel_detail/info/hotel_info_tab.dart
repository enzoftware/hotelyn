import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

class HotelInformationTab extends StatelessWidget {
  const HotelInformationTab({
    Key key,
    @required this.hotel,
  }) : super(key: key);

  final HotelModel hotel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          hotel.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w700,
          ),
        ),
        Divider(height: 2, color: Colors.grey),
        SizedBox(height: 16),
        Text(hotel.description)
      ],
    );
  }
}
