import 'package:flutter/material.dart';

class HotelynAvatar extends StatelessWidget {
  const HotelynAvatar({
    super.key,
    required this.path,
    required this.size,
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
