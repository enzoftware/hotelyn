import 'package:flutter/material.dart';
import 'package:hotelyn_components/colors/colors.dart';

class HInputField extends StatelessWidget {
  const HInputField({
    super.key,
    required this.controller,
    this.title = '',
    this.placeholder = '',
    this.icon,
    this.keyboardType,
  });

  final String title;
  final String placeholder;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            hintText: placeholder,
            icon: Icon(icon),
            focusColor: HColorsPrimary.blue,
            iconColor: HColorsPrimary.blue,
          ),
          controller: controller,
        )
      ],
    );
  }
}
