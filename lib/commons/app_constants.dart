import 'package:flutter/material.dart';

class AppCommons {
  static _Colors colors = _Colors();
  static _Dimens dimens = _Dimens();
}

class _Colors {
  final Color backgroundColor = Color(0xFFe2d7f5);
  final Color primaryColor = Color(0xff6732c1);
  final Color accentColor = Color(0xff4caf50);
}

class _Dimens {
  final double radiusBorderValue = 20.0;
  final double activeTabIconSize = 30.0;
  final double activeTabTextSize = 18.0;
}
