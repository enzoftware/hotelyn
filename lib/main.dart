import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/ui/pages/hotel_search/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) => LifeErrorWidget();
  runApp(MyApp());
}

class LifeErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.network(
          "https://i.pinimg.com/originals/3f/87/c5/3f87c5b2a2e06bfaf5d37d974f607a02.jpg",
          width: 200,
          height: 200,
        ),
        Text(
          "Ocurrio un error :(",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ));
  }
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
