import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HotelynSearchInput extends StatelessWidget {
  const HotelynSearchInput({
    required this.hintText,
    super.key,
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.enabled,
    this.onChanged,
    this.onSubmitted,
  });

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool? enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  double get _radius => 30;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: LightGreyColors.lightGrey,
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
