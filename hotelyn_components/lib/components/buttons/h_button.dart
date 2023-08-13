import 'package:flutter/material.dart';
import 'package:hotelyn_components/colors/colors.dart';

class HButton extends StatelessWidget {
  const HButton({
    super.key,
    required this.text,
    this.onTap,
    this.width = 176,
  });

  factory HButton.large({
    required String text,
    VoidCallback? onTap,
  }) =>
      HButton(
        text: text,
        onTap: onTap,
        width: 256,
      );

  factory HButton.xlarge({
    required String text,
    VoidCallback? onTap,
  }) =>
      HButton(
        text: text,
        onTap: onTap,
        width: 328,
      );

  final String text;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MaterialButton(
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        color: HColorsPrimary.blue,
        textColor: HColorsPrimary.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(48.0),
        ),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
