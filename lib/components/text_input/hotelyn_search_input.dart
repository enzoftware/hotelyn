import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HotelynSearchInput extends StatelessWidget {
  const HotelynSearchInput({
    required this.hintText,
    super.key,
    this.controller,
  });

  final String hintText;
  final TextEditingController? controller;

  double get _radius => 30;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
