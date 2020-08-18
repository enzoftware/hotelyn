import 'package:flutter/material.dart';

class HotelPriceText extends StatelessWidget {
  final double price;

  const HotelPriceText({Key key, this.price}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      '\$' + price.toString(),
      style: TextStyle(
        color: Colors.black,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
