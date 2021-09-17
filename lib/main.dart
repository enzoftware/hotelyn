import 'dart:io';
import 'package:hotel_booking_app/commons/theme.dart';
import 'package:hotel_booking_app/dependencies.dart';
import 'package:hotel_booking_app/features/home/ui/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widgets/error_widget.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  ErrorWidget.builder =
      (FlutterErrorDetails details) => const CustomErrorWidget();
  setupDependencies();
  runApp(const HotelBookingApp());
}

class HotelBookingApp extends StatelessWidget {
  const HotelBookingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking App',
      theme: ThemeData(
        primarySwatch: primarySwatch,
        primaryColor: primaryColor,
        fontFamily: 'avenir',
        cardColor: Colors.white,
      ),
      home: HotelSearchPage.init(),
    );
  }
}
