import 'package:flutter/material.dart';

class HotelynIcon extends StatelessWidget {
  const HotelynIcon({super.key, this.width = 82, this.height = 82});

  static const path = 'assets/icons/ic_hotelyn.png';

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
    );
  }
}
