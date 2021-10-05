import 'package:flutter/material.dart';

class AppCommons {
  static _Colors colors = _Colors();
  static _Dimens dimens = _Dimens();
}

class _Colors {
  final Color backgroundColor = const Color(0xFFe2d7f5);
  final Color primaryColor = const Color(0xff6732c1);
  final Color accentColor = const Color(0xff4caf50);
}

class _Dimens {
  final int radiusBorderValue = 20;
  final int activeTabIconSize = 30;
  final int activeTabTextSize = 18;
}
