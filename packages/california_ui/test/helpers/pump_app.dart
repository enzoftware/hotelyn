import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [widget] wrapped in a minimal [MaterialApp], mirroring the
/// `pumpApp` helper used by `apps/hotelyn_app`'s test suite.
///
/// This package ships no localization delegates of its own — widgets here
/// take already-localized strings from their callers — so no
/// `localizationsDelegates`/`supportedLocales` wiring is needed.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: widget))),
    );
  }
}
