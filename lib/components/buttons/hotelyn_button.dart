import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HotelynButton extends StatelessWidget {
  const HotelynButton({
    super.key,
    required this.message,
    this.onPressed,
    this.height = 56,
    this.width = double.infinity,
    this.color = HotelynAppColors.blue,
    this.textColor = HotelynAppColors.white,
  });

  factory HotelynButton.secondary({
    required String message,
    VoidCallback? onPressed,
    double? height,
    double? width,
    Color? color,
    Color? textColor,
  }) {
    return HotelynButton(
      message: message,
      onPressed: onPressed,
      height: height ?? 56,
      width: width ?? double.infinity,
      color: HotelynAppColors.white,
      textColor: HotelynAppColors.blue,
    );
  }

  final VoidCallback? onPressed;
  final String message;
  final double height;
  final double width;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: width,
      onPressed: onPressed,
      height: height,
      shape: const StadiumBorder(),
      color: color,
      textColor: textColor,
      elevation: 0,
      child: Text(message),
    );
  }
}
