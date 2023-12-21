import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

abstract class HotelynTextStyle {
  static const h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: HotelynAppColors.black,
  );

  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: HotelynAppColors.black,
  );

  static const h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: HotelynAppColors.black,
  );

  static const description = TextStyle(
    color: HotelynAppColors.grey,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
