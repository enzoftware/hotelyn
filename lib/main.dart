import 'dart:io';

import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/ui/pages/hotel_search/home_page.dart';
import 'package:buscatelo/ui/utils/error_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) => CustomErrorWidget();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: ChangeNotifierProvider(
        create: (_) => HotelBloc()..retrieveHotels(),
        child: HotelSearchPage(),
      ),
    );
  }
}
