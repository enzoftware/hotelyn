import 'package:flutter/material.dart';

/// [HotelynColors] -
/// Our colour palette is built with our core principles and guidelines as
/// its foundation.
class HotelynColors {
  HotelynColors._();

  // Primary Colors
  static const primary = PrimaryColors();

  // Other Colors
  static const grey = GreyColors();
  static const green = GreenColors();
  static const red = RedColors();
  static const yellow = YellowColors();
  static const lightGrey = LightGreyColors();

  // Additional Blue Shades
  static const blue2 = Blue2Colors();

  // Dark Mode Colors
  static const darkMode = DarkModeColors();
}

/// Primary color palette
class PrimaryColors {
  const PrimaryColors();

  static const blue = Color(0XFF3D5BF6);
  static const blue2 = Color(0XFF7F9EF9);
  static const blue3 = Color(0XFF9FB6FA);

  static const black = Color(0XFF151B33);
  static const black2 = Color(0XFF636777);
  static const black3 = Color(0XFF8A8D99);

  static const white = Color(0XFFFFFFFF);
  static const white2 = Color(0XFFD4D4D4);
  static const white3 = Color(0XFFAAAAAA);
}

/// Grey color palette
class GreyColors {
  const GreyColors();

  static const grey = Color(0XFFA7AEC1);
  static const grey2 = Color(0XFFC4C9D6);
  static const grey3 = Color(0XFFE2E4EA);
}

/// Green color palette
class GreenColors {
  const GreenColors();

  static const green = Color(0XFF13B97D);
  static const green2 = Color(0XFF62D0A8);
  static const green3 = Color(0XFFB0E8D4);
}

/// Red color palette
class RedColors {
  const RedColors();

  static const red = Color(0XFFFF4747);
  static const red2 = Color(0XFFFF8484);
  static const red3 = Color(0XFFFFC2C2);
}

/// Yellow color palette
class YellowColors {
  const YellowColors();

  static const yellow = Color(0XFFFFBA55);
  static const yellow2 = Color(0XFFFFD18E);
  static const yellow3 = Color(0XFFFFE8C6);
}

/// Light grey color palette
class LightGreyColors {
  const LightGreyColors();

  static const lightGrey = Color(0XFFF9F9F9);
  static const lightGrey2 = Color(0XFFE7E7E7);
  static const lightGrey3 = Color(0XFFCFCFCF);
}

/// Additional blue shades
class Blue2Colors {
  const Blue2Colors();

  static const blue2_1 = Color(0XFF3F6DF6);
  static const blue2_2 = Color(0XFF7F9EF9);
  static const blue2_3 = Color(0XFFBFCEFC);
}

/// Dark mode color palette
class DarkModeColors {
  const DarkModeColors();

  static const black1 = Color(0XFF111315);
  static const black2 = Color(0XFF202427);
  static const black3 = Color(0XFF292E32);
}
