import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HotelynTextInput extends StatelessWidget {
  const HotelynTextInput({
    required this.hintText,
    super.key,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.errorText,
    this.prefixIcon,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final IconData? prefixIcon;

  double get _radius => 30;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: LightGreyColors.lightGrey,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radius)),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        errorText: errorText,
      ),
    );
  }
}
