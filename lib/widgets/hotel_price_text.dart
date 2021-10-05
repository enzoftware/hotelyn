import 'package:flutter/material.dart';

class HotelPriceText extends StatelessWidget {
  const HotelPriceText({Key? key, this.price = 0.0}) : super(key: key);

  final double price;

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$ $price',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
