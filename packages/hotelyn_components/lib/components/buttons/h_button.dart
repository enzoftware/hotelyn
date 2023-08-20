import 'package:flutter/material.dart';
import 'package:hotelyn_components/colors/colors.dart';

class HButton extends StatelessWidget {
  const HButton({
    super.key,
    required this.text,
    this.onTap,
    this.width = 176,
    this.textColor = HColorsPrimary.white,
    this.backgroundColor = HColorsPrimary.blue,
  });

  factory HButton.ghost({
    required String text,
    double width = 176,
    VoidCallback? onTap,
  }) =>
      HButton(
        text: text,
        onTap: onTap,
        width: width,
        textColor: HColorsPrimary.blue,
        backgroundColor: HColorsPrimary.white,
      );

  final String text;
  final VoidCallback? onTap;
  final double width;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MaterialButton(
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        color: backgroundColor,
        disabledColor: HColorsOther.grey2,
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
