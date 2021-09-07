import 'dart:io';
import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/dependencies.dart';
import 'package:buscatelo/features/home/ui/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widgets/error_widget.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) => CustomErrorWidget();
  setupDependencies();
  runApp(HotelBookingApp());
}

class HotelBookingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking App',
      theme: ThemeData(
        primarySwatch: primarySwatch,
        primaryColor: primaryColor,
        accentColor: accentColor,
        fontFamily: 'avenir',
        cardColor: Colors.white,
      ),
      home: HotelSearchPage.init(),
    );
  }
}
