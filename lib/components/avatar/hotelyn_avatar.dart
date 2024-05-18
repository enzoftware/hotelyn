import 'package:flutter/material.dart';

class HotelynAvatar extends StatelessWidget {
  const HotelynAvatar({
    required this.path,
    required this.size,
    super.key,
  });

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      child: Image.asset(path),
    );
  }
}
