import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HotelynSearchInput extends StatelessWidget {
  const HotelynSearchInput({
    super.key,
    required this.hintText,
    this.controller,
  });

  final String hintText;
  final TextEditingController? controller;

  final _radius = 30.0;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: HotelynAppColors.lightGrey,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
      ),
    );
  }
}
